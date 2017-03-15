require "yaml"
require "json"

module Mantra
  class Commands
    class Find < Command
      type :find
      aliases :f
      description "Transform manifest using transform config"

      option :scope,       "--scope scope-path",       "-s scope",         "path scope you want to find"
      option :manifest,    "--manifest manifest-file", "-m manifest-file", "manifest"
      option :format,      "--format format",          "-f format",        "format (yaml or json)"
      option :with_parent, "--with-parent",            "-p",               "format (yaml or json)"

      def perform
        m = Manifest.new(manifest)
        results = m.select(scope)

        results = results.map do |element|
          element.parent
        end if with_parent

        results = results.map do |element|
          element.to_ruby_object
        end

        case format
        when "yaml", "yml", "y", nil
          puts results.to_yaml
        when "json", "j"
          puts JSON.pretty_generate(results)
        else
          raise "unknown format"
        end
      end

    end
  end
end
