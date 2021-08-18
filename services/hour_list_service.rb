require "./lib/employee/shifts/hourlist_csv_parser"

class HourListService
    def get_monthly_wages(file_data)
        parser = HourlistCsvParser.new(file_data)
        parser.monthly_wages
    end
end 