require "optparse"

module Mantra
  class Command
    include Helpers::ObjectWithType

    def self.option_descriptors
      @options ||= []
    end

    def self.usage
      "Mantra is Manifest Transformation tool to ease work with BOSH manifest.\n" +
      "\nUsage:\tmantra <command> [options]" +
      "\n\nCommands:\n" + 
      self.subclasses.map { |s| "#{" "*6}#{s.type}#{" "*20}\t#{s.description}" }.join("\n") +
      "\n\n" +
      "For help on any command run:\n" +
      ["mantra <command> -h", "mantra <command> help", "mantra <command> --help"].map { |s| " " * 6 + s }.join("\n") +
      "\n\n"
    end

    def self.description(description=nil)
      description.nil? ? full_description : (@description = description)
    end

    def self.full_description
      [@description, aliases.empty? ? nil : "(aliases: #{aliases.join(", ")})"].compact.join(" ")
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
        options_parser.banner = "Usage: mantra [options]"
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
require "mantra/commands/merge"
require "mantra/commands/transform"
require "mantra/commands/highlight"
require "mantra/commands/render_release_template"
require "mantra/commands/detect_certificates"
require "mantra/commands/help"
