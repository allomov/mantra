require "yaml"

module Mantra
  class Commands
    class Transform < Command
      type :transform
      alias_type :t
      attr_accessor :manifest

      option :transform_config_path, "--config CONFIG",     "-t", "Transformation config path"
      option :manifest_path,         "--manifest MANIFEST", "-m", "Manifest path"

      def transform_config
        @transform_config ||= YAML.load_file(transform_config_path)
      end

      def transforms
        previous_transform = self
        transform_config["transforms"].map do |options|
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
      end

    end
  end
end
