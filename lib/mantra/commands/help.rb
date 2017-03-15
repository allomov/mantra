require "yaml"
require "json"

module Mantra
  class Commands
    class Help < Command
      type :help
      description "Print help message"

      def perform
        puts Mantra::Command.usage
        exit 0        
      end

    end
  end
end
