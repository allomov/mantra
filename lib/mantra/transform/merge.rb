module Mantra
  class Transform
    class Merge < Mantra::Transform
      type :"merge"
      attr_accessor :manifest

      description "Merge"

      input "value", description: "value that should be merged in", type: :any

      input "scope",  description: "scope (or path) in stub file that will have current value (for instance meta.networks)",
                      type:        :string

      def perform
        @manifest = previous_transform.manifest
        value_manifest_element = Mantra::Manifest::Element.create(self.value).content

        scope = @manifest.fetch(self.scope)
        scope.each do |s|
          s.merge(value_manifest_element)
        end
      end

    end
  end
end
