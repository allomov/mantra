require "yaml"
require "json"

module Mantra
  class Commands
    class Highlight < Command
      type :highlight
      aliases :h
      description "Highlight manifest path or values"

      option :scope,       "--scope scope-path",       "-s scope",         "path scope you want to highlight"
      option :value,       "--value value",            "-v value",         "value to highlight"
      option :regex,       "--regex value",            "-r regex",         "regex of value to highlight"
      option :manifest,    "--manifest manifest-file", "-m manifest-file", "manifest file"

      def perform
        m = Manifest.new(manifest)
        raise "Not implemented yet"
      end

    end
  end
end
