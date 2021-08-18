namespace :employees do
    task :import_hourlist_csv do
        filename = ENV["HOURLIST_CSV_FILE"]
        puts filename
        # if filename.blank? 
        #     raise "error"
        # end
    end
end