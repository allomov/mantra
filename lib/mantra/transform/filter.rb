module Mantra
  class Transform
    class Filter < Mantra::Transform
      type :filter
      attr_accessor :result

      description "Filter"

      input "sections", description: "list of paths to elements that should be left after this transform ", type: :any

      def perform
        @result = Mantra::Manifest::Element.create({})
        @manifest = previous_transform.result
        sections.each do |p|
          elements = @manifest.select(p)
          elements.each do |e|
            direct_path = e.path
            root_element_to_merge = Mantra::Manifest::Element.element_with_selector(direct_path, e.content)
            @result.merge(root_element_to_merge)
          end
        end
      end

    end
  end
end
