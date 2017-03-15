require "yaml"
require "json"

module Mantra
  class Commands
    class RenderReleaseTemplate < Command
      type :"render-release-template"
      aliases "render-template", "rt", "rrt"
      description "Transform manifest using transform config"

      option :release_folder, "--release-folder release-folder", "-r scope",         "path scope you want to find"
      option :template_name,  "--template template-path",        "-m manifest-file", "manifest"
      option :context,        "--context format",                 "-f format",        "format (yaml or json)"
      option :context_file,   "--context-file",                   "-p",               "format (yaml or json)"

      def perform
      	# see this gist: https://gist.github.com/allomov/c2e7780384674fa85486cc3c3f6bf54f
        raise "Not implemented yet"
      end

    end
  end
end
