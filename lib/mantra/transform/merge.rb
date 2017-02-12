module Mantra
  class Transform
    class Merge < Mantra::Transform
      type :merge

      description "Merge"

      input "value", description: "value that should be merged in", type: :any

      input "to", description: "scope (or path) in stub file that will have current value (for instance meta.networks)",
                  type:        :string
      alias_method :scope, :to

      def perform
        @manifest = previous_transform.result
        element_to_merge = Mantra::Manifest::Element.create(self.value).content

        scope_elements = @manifest.select(self.scope)
        scope_elements.each do |element_from_scope|
          element_from_scope.merge(element_to_merge)
        end
      end

      def result
        @manifest
      end
    end
  end
end
