require 'email_finder/employee'
require 'email_finder/email_resolver'

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
          rescue Exception
            retries+=1
            retry if retries <= MAX_RETRIES
            next
          end
        end

      end.compact

      # Find the most reoccurring email pattern across employees
      unless resolve_unfound_emails(@employees)
        # If we didn't find an email pattern from one of the employees
        # go find examples across Google for the domain
        #  and figure out the pattern from that
        resolve_by_search_sampling
      end

      self
    end

    def email_for(first_name, last_name)
      employees.find do |e|
        e.first_name == first_name &&
          e.last_name == last_name
      end
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
      self
    end

    def resolve_by_search_sampling
      resolver = EmailResolver.new(domain)
      pattern_index = resolver.pattern_index
      return unless pattern_index

      employees.each do |employee|
        employee.email = employee.email_for pattern_index
      end

      self
    end

    def top_employee(employees)
      employees.max_by(&:score)
    end
  end

end