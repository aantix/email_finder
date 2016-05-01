require 'google-search'
require 'email_finder/email_variants'

module EmailFinder
  class Employee
    include EmailVariants

    MAX_SEARCH_VARIANTS = 4

    attr_reader :first_name, :last_name
    attr_reader :domain, :variants, :score
    attr_accessor :probable_email

    def initialize(first_name, last_name, domain)
      @first_name = first_name.downcase
      @last_name  = last_name.downcase
      @domain     = domain.gsub('www.', '')
      @variants   = email_variants(@first_name, @last_name)
      @score      = nil
    end

    def search
      variant_counts = Hash.new(0)

      variants.each_slice(MAX_SEARCH_VARIANTS) do |emails|
        results = ::Google::Search::Web.new(query: query(emails))

        results.each do |search_result|
          found_email = summary_scan_for_email(emails, search_result)
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
      variants.index(email)
    end

    def email_for(index)
      variants[index]
    end

    private

    def full_email(email, domain)
      "#{email}@#{domain}"
    end

    def top_occurring(counts)
      return [nil, nil] if counts.empty?
      counts.sort_by{|_k, v| v}.reverse[0] # first item of the first result
    end

    def query(emails)
      emails.collect{|email| "\"#{full_email(email, domain)}\""}.join(" OR ")
    end

    def summary_scan_for_email(emails, search_result)
      emails.find { |email| search_result.content =~ /\b#{full_email(email, domain)}\b/i }
    end
  end
end