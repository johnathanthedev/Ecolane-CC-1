class Person
    attr_accessor :full_name, :person_id, :shifts, :earnings, :evening_hours_worked, :non_evening_hours_worked
    
    def initialize(full_name, person_id)
        @full_name = full_name
        @person_id = person_id
        @shifts = []
        @evening_hours_worked = 0
        @non_evening_hours_worked = 0
        @earnings = 0
    end
end