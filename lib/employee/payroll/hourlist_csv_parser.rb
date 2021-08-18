require "csv"

class Employee::Payroll::HourlistCsvParser
    def initialize(file_contents)
        @csv_content = CSV.parse(file_contents, headers: true)
    end
end