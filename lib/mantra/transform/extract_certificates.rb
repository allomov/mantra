module Mantra
  class Transform
    class ExtractCertificates < Transform
      type :"extract-certificates"

      description "Extracts certificates from source manifest, " +
                  "templatize source manifest and places certificates to target manifest."
      input "source", type: :file,
                      validate: :file_exists,
                      description: "Source manifest with ceritificates, that will become a template"
      input "target", type: :file,
                      description: "Target manifest with extracted ceritificates"



    end
  end
end
