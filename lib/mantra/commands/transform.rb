module Mantra
  class Commands
    class Transform < Command
      type :transform
      alias_type :t

      option :transform_config_path, "--config",   "-c", "Transformation config path"
      option :manifest_path,         "--manifest", "-m", "Manifest path"

      def transform_config
        @transform_config ||= YAML.load_file(transform_config_path)
      end

      def transforms
        transform_config["transforms"].map do |t|
          t.merge(manifest: self.manifest_path) if self.manifest_path
          Transform.create(t)
        end
      end

      def perform
        transforms.each do |t|
          t.run
        end
      end

    end
  end
end
