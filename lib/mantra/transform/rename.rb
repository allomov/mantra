module Mantra
  class Transform
    class Rename < Mantra::Transform
      type :rename
      attr_accessor :result

      description "Rename section"

      input "section", description: "path to the section that should be renamed ", type: :any
      input "to",      description: "new name for the section", type: :any
      alias_method :new_name, :to

      def perform
        @result = Mantra::Manifest::Element.create({})
        manifest = previous_transform.result
        elemenents_to_rename = manifest.select(section)
        elemenents_to_rename.each do |element|
          parent = element.parent
          raise "parent should be a hash" unless parent.hash?
          old_name = parent.selector_for(element)
          parent.content[new_name] = element.content
          parent.content.delete(old_name)
        end
      end

    end
  end
end
