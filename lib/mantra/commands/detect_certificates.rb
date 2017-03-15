module Mantra
  class Commands
    class DetectCertificates < Command
      type :"detect-certificates"
      aliases "certs", "dc"
      description "Find and group certificates in manifest"

      option :manifest,    "--manifest manifest-file", "-m manifest-file", "manifest file"

      def perform
        m = Manifest.new(manifest)
        raise "Not implemented yet"
      end

    end
  end
end
