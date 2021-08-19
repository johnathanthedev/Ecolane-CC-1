require "./services/hour_list_service"

namespace :employees do
    task :import_hourlist_csv do
        filename = ENV["HOURLIST_CSV_FILE"]

        if filename.empty? 
            raise "No HourList CSV file specified. Set the 'HOURLIST_CSV_FILE' environment variable to a full file path and run this task again"
        end

        # Load data from HourList CSV File
        file_data = open(filename).read
        hour_list_service = HourListService.new()
        monthly_wages = hour_list_service.get_monthly_wages(file_data)
    end
end