module Mantra
  module Helpers
    module RegexpHelper

      def to_regexp(string)
        escaped_string = Regexp.escape(string)
        Regexp.new("^#{escaped_string.gsub("\\*", ".+")}$")
      end

    end
  end
end
