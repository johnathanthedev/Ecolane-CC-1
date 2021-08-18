class Person
    attr_accessor :full_name, :person_id, :shifts, :earnings
    
    def initialize(full_name, person_id)
        @full_name = full_name
        @person_id = person_id
        @shifts = []
        @earnings = 0
    end
end