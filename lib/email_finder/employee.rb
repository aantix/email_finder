require 'email_finder/email_variants'

module EmailFinder
  class Employee
    include EmailVariants

    MAX_SEARCH_VARIANTS = 4

    attr_reader :first_name, :last_name
    attr_reader :domain, :email_variations, :score
    attr_accessor :probable_email

    def initialize(first_name, last_name, domain)
      @first_name       = first_name.downcase
      @last_name        = last_name.downcase
      @domain           = domain.gsub('www.', '')
      @email_variations = email_variants(@first_name, @last_name)
      @score            = nil
    end

    def search
      variant_counts = Hash.new(0)

      # Search for MAX_SEARCH_VARIANTS variants and see if they
      #  exist out on the web.
      email_variations.each_slice(MAX_SEARCH_VARIANTS) do |emails|
        results = ::DistributedSearch::DistributedSearch.new.search(query(emails))

        results['results'].each do |search_result|
          found_email = summary_scan_for_email(emails, search_result['content'])
          variant_counts[found_email]+=1 if found_email
        end
      end

      @probable_email, @score = top_occurring(variant_counts)
    end

    def pattern_index
      return nil unless probable_email
      pattern_index_for probable_email
    end

    def pattern_index_for email
      email_variations.index(email.downcase)
    end

    def email_for(index)
      email_variations[index]
    end

    def email_pattern
      return nil unless pattern_index
      pattern_variants[pattern_index]
    end

    private

    def full_email(email, domain)
      "#{email}@#{domain}"
    end

    def top_occurring(counts)
      return [nil, nil] if counts.empty?
      counts.sort_by{|_k, v| v}.reverse[0] # first item of the first result
    end

    def pattern_variants
      variants(@first_name, @last_name).keys
    end

    def query(emails)
      emails.collect{|email| "\"#{full_email(email, domain)}\""}.join(" OR ")
    end

    def summary_scan_for_email(emails, content)
      emails.find { |email| content =~ /\b#{full_email(email, domain)}\b/i }
    end
  end
end