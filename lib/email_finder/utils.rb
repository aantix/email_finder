module EmailFinder
  module Utils
    def strip_html(string)
      string.gsub(/<\/?[^>]*>/, "")
    end

    def root
      File.dirname __dir__
    end
  end
end