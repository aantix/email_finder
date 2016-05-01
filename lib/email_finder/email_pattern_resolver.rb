require 'erb'

module EmailFinder
  class EmailPatternResolver
    attr_reader :username

    FIRST_NAMES = "../../data/first_names.txt"
    LAST_NAMES  = "../../data/last_names.txt"

    def initialize(username)
      @username = username
    end

    def pattern
      email_template = username
      temp_username  = username

      last_name  = scan_and_replace(username, email_template, temp_username,
                                    'last_name', last_names)
      first_name = scan_and_replace(username, email_template, temp_username,
                                    'first_name', first_names)

      remove_delimiters(temp_username)

      # Any remaining chars?
      if temp_username.size > 0

        if last_name && !first_name
          email_template.gsub(username, "<%= first_name[#{username.size}] %>")
        elsif !last_name && first_name
          email_template.gsub(username, "<%= last_name[#{username.size}] %>")
        else
          return nil # extraneous chars that aren't equal to a first or last name
          # can't extract a general email pattern with an example like that
          # e.g. jjones857@aantix.com (not everyone would have an 857)
        end
      end

      email_template
    end

    def self.name_for(first_name, last_name, template)
      ERB.new(template).result
    end

    private

    def read_names(filename)
      File.open(filename).readlines
    end

    def first_names
      @first_names||=read_names(FIRST_NAMES)
    end

    def last_names
      @last_names||=read_names(LAST_NAMES)
    end

    def find_name(username, names)
      names.find { |name| username =~ name }
    end

    def remove_delimiters(temp_username)
      ['.', '_', '-'].each { |c| temp_username.gsub(c, '') }
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

