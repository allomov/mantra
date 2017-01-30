module Mantra
  class Transform
    class Rename < Mantra::Transform
      type :rename
      attr_accessor :manifest
      alias_method :result, :manifest

      description "Rename section"

      input "section", description: "path to the section that should be renamed ", type: :any
      input "to",      description: "new name for the section", type: :any
      alias_method :new_name, :to

      def perform
        @manifest = previous_transform.result
        puts "before"
        puts @manifest.to_ruby_object.to_json
        elemenents_to_rename = @manifest.select(section)
        elemenents_to_rename.each do |element|
          parent = element.parent
          puts "parent"
          puts parent.parent.to_ruby_object.to_yaml
          unless parent.hash?
            raise Mantra::Transform::ValidationError.new ("parent should be a hash, not #{parent.type}") 
          end
          unless parent.find(new_name).nil?
            raise Mantra::Transform::ValidationError.new("Section with the name #{new_name} already exists.")
          end
          old_name = parent.selector_for(element)
          puts old_name
          parent.content[new_name] = element
          puts new_name
          puts parent.content[new_name].to_ruby_object.to_json
          parent.content.delete(old_name)
          puts parent.to_ruby_object.to_json
          puts "after"
          puts @manifest.to_ruby_object.to_json
        end
        puts "after"
        # puts @manifest.to_ruby_object.to_json
      end

    end
  end
end
