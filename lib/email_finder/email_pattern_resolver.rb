require 'erb'
require 'email_finder/utils'

module EmailFinder
  class EmailPatternResolver
    include Utils
    attr_reader :username

    FIRST_NAMES = "data/first_names.txt"
    LAST_NAMES  = "data/last_names.txt"

    def initialize(username)
      @username = username.downcase
    end

    def pattern
      email_template = username.dup
      temp_username  = username.dup

      last_name  = scan_and_replace(username, email_template, temp_username,
                                    'last_name', last_names)
      first_name = scan_and_replace(temp_username, email_template, temp_username,
                                    'first_name', first_names)

      remove_delimiters(temp_username)

      # Any remaining chars?
      if temp_username.size > 0
        if last_name && !first_name
          email_template.gsub!(temp_username, "<%= first_name[0..#{temp_username.size - 1}] %>")
        elsif !last_name && first_name
          email_template.gsub!(temp_username, "<%= last_name[0..#{temp_username.size - 1}] %>")
        else
          return nil # extraneous chars that aren't equal to a first or last name
          # can't extract a general email pattern with an example like that
          # e.g. jjones857@aantix.com (not everyone would have an 857)
        end
      end

      email_template
    end

    def self.name_for(first_name, last_name, template)
      ERB.new(template).result(binding)
    end

    def first_name?
      find_name(username, first_names).present?
    end

    def last_name?
      find_name(username, last_names).present?
    end

    private

    def read_names(filename, min)
      File.readlines(File.join([root, "..", filename]), "\r")
          .collect(&:chomp!)
          .find_all{|n| n && n.size >= min}
          .collect(&:downcase)
    end

    def first_names
      @first_names||=read_names(FIRST_NAMES, 3)
    end

    def last_names
      @last_names||=read_names(LAST_NAMES, 5)
    end

    def find_name(username, names)
      names.find { |name| username =~ /#{name.chomp}/ }
    end

    def remove_delimiters(temp_username)
      ['.', '_', '-'].each { |c| temp_username.gsub!(c, '') }
    end

    def scan_and_replace(username, email_template, temp_username, placeholder, names)
      name = find_name(username, names)

      if name
        email_template.gsub!(name, "<%= #{placeholder} %>")
        temp_username.gsub!(name, '')
      end

      name
    end

  end
end

