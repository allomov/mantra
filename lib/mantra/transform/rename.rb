module Mantra
  class Transform
    class Rename < Mantra::Transform
      type :rename
      attr_accessor :manifest

      description "Rename section"

      input "section", description: "path to the section that should be renamed ", type: :any
      input "to",      description: "new name for the section", type: :any
      alias_method :new_name, :to
      alias_method :result, :manifest

      def perform
        @manifest = previous_transform.result
        unless @manifest.find(new_name).nil?
          raise Mantra::Transform::ValidationError.new("Section with the name #{new_name} already exists.") 
        end
        elemenents_to_rename = @manifest.select(section)

        elemenents_to_rename.each do |element|
          parent = element.parent
          raise "parent should be a hash" unless parent.hash?
          old_name = parent.selector_for(element)
          parent.content[new_name] = element
          parent.content.delete(old_name)
        end
      end

    end
  end
end
