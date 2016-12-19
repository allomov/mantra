module Mantra
  class Transform
    class Replace < Mantra::Transform
      type :"replace"
      attr_accessor :manifest

      description "Merge"

      input "value", description: "value that should be merged in", type: :any

      input "scope",  description: "scope (or path) in stub file that will have current value (for instance meta.networks)",
                      type:        :string

      def perform
        @manifest = previous_transform.manifest
        # value_manifest_element = Mantra::Manifest::Element.create(self.value).content

        scope = @manifest.fetch(self.scope)
        scope.each do |s|
          puts "psssss!!"
          puts s.class
          s.content = self.value
        end
      end

      def raise_if_no_source_manifest
        if self.source.nil? || !File.exist?(self.source)
          raise Manifest::FileNotFoundError.new("Source manifest does not exist: #{self.source.inspect}")
        end
      end

    end
  end
end
