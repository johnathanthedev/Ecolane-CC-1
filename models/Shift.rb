class Shift
    attr_accessor :date, :start_time, :end_time

    def initialize(date, start_time, end_time)
        @date = date
        @start_time = start_time
        @end_time = end_time
    end
end