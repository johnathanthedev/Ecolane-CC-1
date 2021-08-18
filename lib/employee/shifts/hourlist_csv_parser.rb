require "csv"
require 'date'
require "time"
require "./models/Person"
require "./models/Shift"
require "./models/Wage"

class HourlistCsvParser
    def initialize(file_contents)
        @csv_content = CSV.parse(file_contents, headers: true)
        @unique_persons = []
        @shift_dates = []
        @calendar_dates = []
    end

    def monthly_wages
        @csv_content.each.map { |row| unique_persons(row) }
        @unique_persons = @unique_persons.uniq { |person| person.person_id }
        @unique_persons.each { |person| get_all_employee_info(person) }
        log_wages()        
    end

    private 

    def unique_persons(parsed_row)
        person_name = parsed_row["Person Name"].to_s
        person_id = parsed_row["Person ID"].to_i

        person = Person.new(person_name, person_id)
        @unique_persons << person
    end

    def get_all_employee_info(person)
        @csv_content.each.map { |row| parse_employee_info(person, row) }
    end

    def parse_employee_info(person, row)
        if row["Person ID"].to_i == person.person_id 
            date = row["Date"].to_s
            start_time = row["Start"].to_s
            end_time = row["End"].to_s

            shift = Shift.new(date, start_time, end_time)
            person.shifts << shift            
        end
    end

    def log_wages
        @unique_persons.each { |person| get_dates(person) }
        @calendar_dates.each { |calendar_date| create_log(calendar_date) }
    end

    def get_dates(person)
        person.shifts.each { |shift| @shift_dates << shift.date  }
        @shift_dates.each { |date| @calendar_dates << Time.parse(date).strftime("%m/%Y") }
        @calendar_dates = @calendar_dates.uniq
        @calendar_dates = @calendar_dates.sort_by { |date| Date.strptime(date, '%m/%Y') }.reverse
    end

    def create_log(calendar_date)
        puts "Monthly Wages #{calendar_date}:"
        @unique_persons.each do |person|
            calc_wages(person, calendar_date) 
        end
    end

    def calc_wages(person, calendar_date)
        worked_on_calendar_date = person.shifts.any? do |shift|
            shift_date = Time.parse(shift.date).strftime("%m/%Y")
            shift_date == calendar_date
        end

        if worked_on_calendar_date 
            person.shifts.each do |shift|
                started_during_evening = shift.start_time.between?(Wage::EVENING_WAGE_START, Wage::EVENING_WAGE_END)
                started_after_evening = shift.start_time >= Wage::EVENING_WAGE_END
                started_during_regular_hours = shift.start_time.between?(Wage::REGULAR_WAGE_START, Wage::REGULAR_WAGE_END)
                started_after_regular_hours = shift.start_time >= Wage::REGULAR_WAGE_END

                evening_check(started_during_evening, started_after_evening, shift, person)
                non_evening_check(started_during_regular_hours, started_after_regular_hours, shift, person)
            end

            formatted_earnings = sprintf("%.2f", person.earnings)
            puts formatted_earnings
        end
    end

    def evening_check(started_during_evening, started_after_evening, shift, person)
        if started_during_evening and !started_after_evening
            formatted_starting_time = create_formatted_starting_time(shift)
            formatted_end_time = create_formatted_end_time(shift)

            difference_in_hours = (((formatted_end_time - formatted_starting_time) * 24 * 60 * 60 ).to_i / 3600).abs # No negatives
            person.evening_hours_worked += difference_in_hours
            non_rounded_earnings = person.evening_hours_worked * Wage::EVENING_HOURLY_WAGE
            person.earnings += non_rounded_earnings
        end 
    end

    def create_formatted_starting_time(shift)
        year = Time.parse(shift.date).strftime("%Y").to_i
        month = Time.parse(shift.date).strftime("%m").to_i
        day = Time.parse(shift.date).strftime("%d").to_i
        hour = Time.parse(shift.start_time).strftime("%H").to_i
        minute = Time.parse(shift.start_time).strftime("%M").to_i

        midnight_check(day, hour)

        formatted_start_time = DateTime.new(year, month, day, hour, minute)
    end

    def create_formatted_end_time(shift)
        year = Time.parse(shift.date).strftime("%Y").to_i
        month = Time.parse(shift.date).strftime("%m").to_i
        day = Time.parse(shift.date).strftime("%d").to_i 
        hour = Time.parse(shift.end_time).strftime("%H").to_i
        minute = Time.parse(shift.end_time).strftime("%M").to_i

        midnight_check(day, hour)

        formatted_start_time = DateTime.new(year, month, day, hour, minute)
    end

    def midnight_check(day, hour)
        if hour >= Time.parse(Wage::MIDNIGHT).strftime("%H").to_i
            day += 1 # Next day. Not checking for total days in month :-) sry
        end
    end

    def non_evening_check(started_during_regular_hours, started_after_regular_hours, shift, person)
        if started_during_regular_hours 
            formatted_starting_time = create_formatted_starting_time(shift)
            formatted_end_time =  create_formatted_end_time(shift)

            difference_in_hours = (((formatted_end_time - formatted_starting_time) * 24 * 60 * 60 ).to_i / 3600).abs # No negatives
            person.non_evening_hours_worked += difference_in_hours
            non_rounded_earnings = person.non_evening_hours_worked * Wage::REGULAR_HOURLY_WAGE
            person.earnings += non_rounded_earnings
        end 
    end
end