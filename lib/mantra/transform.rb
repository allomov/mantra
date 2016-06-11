require "pathname"
require "yaml"

module Mantra
  class Transform
    include Helpers::ObjectWithType

    class ValidationError < Exception; end

    class Input
      include Helpers::ObjectWithType
      def validate(value, name = nil)
        return if self.options[:validate].nil?
        Array(self.options[:validate]).each do |validate_verb|
          # puts "validate_verb: #{validate_verb.inspect}, #{value.inspect}, #{name.inspect}"
          if self.respond_to?("validate_#{validate_verb}")
            self.send(:"validate_#{validate_verb}", value, name)
          else
            raise ValidationError.new("There is no validator defined: #{validate_verb}.")
          end
        end
      end

      def required?
        !self.options[:optional]
      end

      def validate_required(value, name)
        raise ValidationError.new("#{name} must be specified.") if value.nil?
      end
    end

    def self.inputs
      @inputs ||= {}
    end

    def self.input(name, options={type: :string})
      self.inputs[name] = Input.create(options)
      define_method name do
        self.options[name]
      end
      define_method "#{name}_defined?" do
        !self.options[name].nil?
      end
    end

    def self.description(description)
      @description = description
    end

    def run
      validate_inputs
      self.perform
    end

    def validate_inputs
      puts "-" * 30
      puts "validate_inputs: #{self.class.inputs.inspect}"
      self.class.inputs.each_pair do |name, input|
        input_value = self.options[name]
        input.validate_required(input_value, name) if input.required?
        puts
        puts "ITEM     \t'#{name}' : #{input.inspect}"
        puts "OPTIONS  \t#{self.options.inspect}"
        input_value = self.options[name]
        input.validate(input_value, name)
      end
    end

    def perform
      raise "not implemented"
    end

    def ensure_yml_file_exist(path)
      return if File.exist?(path)
      pathname = Pathname.new(path)
      directory = pathname.dirname
      FileUtils.mkdir_p(directory)
      File.open(path, "w+") { |file| file.write({}.to_yaml) }
    end

    def merge_tool
      return @merge_tool unless @merge_tool.nil?
      merge_tool_type = self.options[:merge_tool] || :spiff
      @merge_tool = MergeTool.create(type: merge_tool_type)
    end

  end
end

require "mantra/transform/inputs/string"
require "mantra/transform/inputs/file"
require "mantra/transform/inputs/folder"

require "mantra/transform/extract_section"
require "mantra/transform/extract_certificates"
require "mantra/transform/extract_certificates_to_files"
require "mantra/transform/templatize_value"
