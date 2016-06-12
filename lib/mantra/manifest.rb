require "forwardable"
require "mantra/manifest/element"
require "mantra/manifest/root_element"
require "mantra/manifest/array_element"
require "mantra/manifest/hash_element"
require "mantra/manifest/leaf_element"

module Mantra
  class Manifest

    extend Forwardable

    class UnknownScopeError < Exception; end
    class FileNotFoundError < Exception; end

    attr_accessor :root, :file

    def_delegators :@root, :merge, :to_ruby_object, :traverse, :select, :find, :add_node

    def initialize(manifest_object_or_path)
      if manifest_object_or_path.is_a?(String) && File.exist?(manifest_object_or_path)
        manifest_object = YAML.load_file(manifest_object_or_path)
        self.file = manifest_object_or_path
        self.root = Element.create(manifest_object)
      elsif manifest_object_or_path.is_a?(Hash) || manifest_object_or_path.is_a?(Array)
        self.root = Element.create(manifest_object_or_path)
      else
        raise "Don't know how initialize manifest. Expected existing file path or hash, got #{manifest_object_or_path.class.inspect}: #{manifest_object_or_path.inspect}"
      end
    end

    def write(manifest_path)
      File.open(manifest_path, 'w') { |f| f.write(self.to_ruby_object.to_yaml) }
    end

    def save
      raise FileNotFoundError.new("File is not specified") if self.file.nil?
      self.write(self.file)
    end

  end
end
