module Mantra
  module Helpers
    module RegexpHelper

      def to_regexp(string)
        # TODO: escape all symbols except *
        Regexp.new("^#{string.gsub("*", ".*")}$")
      end

    end
  end
end
