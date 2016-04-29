require 'email_finder/employee'

module EmailFinder
  class Search
    MAX_RETRIES = 3

    attr_reader :names, :domain, :employees

    def initialize(names, domain)
      @names  = names.flatten.each_slice(2).to_a
      @domain = domain
    end

    def search
      @employees = names.inject([]) do |searches, name|

        searches << Employee.new(name[0], name[1], domain).tap do |employee|
          retries = 0
          begin
            employee.search
          rescue Net::TimeOut
            retries+=1
            retry if retries <= MAX_RETRIES
            next
          end
        end

      end.compact

      # Find the most reoccurring email pattern across employees
      resolve_unfound_emails(@employees)

      self
    end

    private
    def resolve_unfound_emails(employees)
      return nil if employees.empty?
      return nil if employees.all? {|e| e.score.nil?}

      top_score = top_employee(employees)

      # For all employees without an email, set their email equal
      #  to the pattern found in the top scoring found sample
      # (using their associated first/last name).
      employees.each do |employee|
        next if employee.probable_email.present?

        employee.probable_email = employee.email_for(top_score.pattern_index)
      end
    end

    def top_employee(employees)
      employees.max_by(&:score)
    end
  end

end