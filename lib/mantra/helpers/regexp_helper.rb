module Mantra
  module Helpers
    module RegexpHelper

      def to_regexp(string)
        Regexp.new("^#{string.gsub("*", ".*")}$")
      end

    end
  end
end
