module Mantra
  class Transform
    class TemplatizeValue < Transform
      type :"templatize-value"
      include Mantra::Helpers::RegexpHelper

      description "Extracts certificates from source manifest, " +
                  "templatize source manifest and places certificates to target manifest."

      input "source", description: "Source manifest with ceritificates, that will become a template",
                      type:        :file,
                      validate:    :file_exists
                      
      input "target", description: "Target manifest with extracted ceritificates",
                      type:        :file

      input "value",  description: "value you want to templatize (wildcard is available, i.e. '*.domain.com')",
                      type:        :string

      input "scope",  description: "scope of element",
                      type:        :string

      def perform
        raise Manifest::FileNotFoundError.new("Source manifest does not exist: #{self.source.inspect}") if self.source.nil? || !File.exist?(self.source)
        ensure_yml_file_exist(self.target)
        source_manifest = Manifest.new(self.source)
        target_manifest = Manifest.new(self.target)
        value_matcher   = to_regexp(value)

        raise "scope must not match value wildcard" if scope.match(value_matcher)

        source_manifest.traverse do |node|
          if node.content.to_s.match(value_matcher)
            match = node.content.to_s.match(value_matcher)[0]
            begin_index = node.content.to_s.index(match)
            end_index   = begin_index + match.size
            final_value = merge_tool.templatize(node.content.to_s, scope, begin_index, end_index)
            node.content = final_value
            scope_element = Manifest::Element.element_with_selector(scope, value)
            target_manifest.merge(scope_element)
          end
        end

        source_manifest.save
        target_manifest.save
      end      

    end
  end
end
