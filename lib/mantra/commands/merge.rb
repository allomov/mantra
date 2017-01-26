require "yaml"
require "json"

module Mantra
  class Commands
    class Merge < Command
      type :merge
      alias_type :m
      attr_accessor :manifest

      option :json,          "--json JSON",         "-j", "json in text format"
      option :file,          "--file MANIFEST",     "-f", "File that should be merged to the manifest (not implemented)"
      option :path,          "--path PATH",         "-p", "Path in Manifest where to merge this value"
      option :manifest_path, "--manifest MANIFEST", "-m", "Manifest path"
      
      # mantra merge -j "{\"var\": $value}" -m manifest.yml -p apps[name=ss]
      def perform
        if json.nil? && file.nil?
          raise "json of file should be specified"
        end
        object_to_merge = JSON.parse(json)
        element_to_merge = Mantra::Manifest::Element.create(object_to_merge)
        manifest = Mantra::Manifest.new(manifest_path)
        manifst_element  = manifest.find(path || "")
        manifst_element.merge(element_to_merge)
        puts manifest.to_ruby_object.to_yaml
      end

    end
  end
end
