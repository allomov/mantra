require "yaml"
require "json"

module Mantra
  class Commands
    class Merge < Command
      type :merge
      aliases :m
      description "Merge object to manifest to specified path"
      
      option :json,          "--json JSON_STRING",  "-j", "String with JSON object that should be merged to the manifest"
      option :file,          "--file JSON_FILE",    "-f", "JSON file that should be merged to the manifest"
      option :yaml_file,     "--yaml YAML_FILE",    "-y", "File that should be merged to the manifest (not implemented)"
      option :path,          "--scope PATH",        "-s", "Scope (or path) in Manifest where to merge this value"
      option :manifest_path, "--manifest MANIFEST", "-m", "Manifest path"

      attr_accessor :manifest
      
      def perform
        if json.nil? && file.nil?
          raise "json of file should be specified"
        end

        json_string = json.nil? ? File.read(file) : json
        object_to_merge = JSON.parse(json_string)
        element_to_merge = Mantra::Manifest::Element.create(object_to_merge)
        manifest = Mantra::Manifest.new(manifest_path)
        manifst_elements  = manifest.select(path || "")
        manifst_elements.each do |e|
          e.merge(element_to_merge, force: true)
        end
        puts manifest.to_ruby_object.to_yaml
      end

    end
  end
end
