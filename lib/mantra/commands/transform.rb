require "yaml"

module Mantra
  class Commands
    class Transform < Command
      type :transform
      aliases :t
      description "Transform manifest using transform config"

      option :transform_config_path, "--config CONFIG",     "-t", "Transformation config path"
      option :manifest_path,         "--manifest MANIFEST", "-m", "Manifest path"

      attr_accessor :manifest

      def transform_config
        @transform_config ||= YAML.load_file(transform_config_path)
      end

      def transforms
        return @transforms unless @transforms.nil?
        previous_transform = self
        @transforms = transform_config["transforms"].map do |options|
          options.merge!(previous_transform: previous_transform)
          previous_transform = Mantra::Transform.create(options)
        end
      end

      def result
        @manifest ||= Manifest.new(self.manifest_path).root
      end

      def perform
        transforms.each do |t|
          t.run
        end
        unless transforms.last.nil?
          puts transforms.last.result.to_ruby_object.to_yaml
        else
          puts {}.to_yaml
        end
      end

    end
  end
end
