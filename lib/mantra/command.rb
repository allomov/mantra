require "optparse"

module Mantra
  class Command
    include Helpers::ObjectWithType

    def self.option_descriptors
      @options ||= []
    end

    def self.usage
      "\n\tUsage:  \tmantra <action> [options]\n" +
      "\tactions:\t#{self.subclasses.map { |s| s.type }.join(", ")}\n\n"
    end

    def self.option(name, long_option, short_option, description)
      self.option_descriptors << [name, long_option, short_option, description]
      self.send(:define_method, name) do
        @options[name.to_s]
      end
    end

    def run
      parse_options
      perform
    end

    def initialize(options)
      @args = options[:args]
    end

    attr_accessor :options
    def parse_options
      @options = {}
      OptionParser.new do |options_parser|
        options_parser.banner = "Usage: mantra #{} [options]"
        self.class.option_descriptors.each do |option|
          option_name = option.shift.to_s
          options_parser.on(*option) do |value|
            @options[option_name] = value
          end
        end
      end.parse!
      @options
    end

  end
end

require "mantra/commands/find"
require "mantra/commands/transform"
