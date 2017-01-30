module Mantra
  class Transform
    class Merge < Mantra::Transform
      type :"merge"

      description "Merge"

      input "value", description: "value that should be merged in", type: :any

      input "to",  description: "scope (or path) in stub file that will have current value (for instance meta.networks)",
                      type:        :string
      alias_method :scope, :to

      def perform
        @manifest = previous_transform.result
        value_manifest_element = Mantra::Manifest::Element.create(self.value).content

        scope = @manifest.fetch(self.scope)
        scope.each do |s|
          s.merge(value_manifest_element)
        end
      end

      def result
        @manifest
      end

    end
  end
end
