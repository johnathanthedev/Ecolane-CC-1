require "csv"
require "./models/Person"
require "./models/Shift"

class HourlistCsvParser
    def initialize(file_contents)
        @csv_content = CSV.parse(file_contents, headers: true)
        @unique_persons = []
    end

    def monthly_wages
        @csv_content.each.map { |row| unique_persons(row) }
        @unique_persons = @unique_persons.uniq { |person| person.person_id }
        @unique_persons.each { |person| get_all_employee_info(person) }
        log_wages()
        # Iterate through person shifts
        # Display wages for each month
        # Create log headline. Ex.: Monthly Wages 03/2014:
        
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
        create_headline_log()
    end

    def create_headline_log
        @unique_persons.each { |person| get_headline_date(person) }
    end

    def get_headline_date(person)
        # get date
        shift_dates = []
        person.shifts.each { |shift| shift_dates << shift.date  }
        puts shift_dates
    end
end