module Mantra
  class Transform
    class TemplatizeValue < Transform
      type :"templatize-value"
      include Mantra::Helpers::RegexpHelper

      description "Extracts specified value to stub file"

      input "source", description: "Source manifest with ceritificates, that will become a template",
                      type:        :file,
                      validate:    :file_exists
                      
      input "target", description: "Target manifest with extracted ceritificates",
                      type:        :file

      input "value",  description: "value you want to templatize (wildcard available, for instance 'domain.com')",
                      type:        :string

      input "scope",  description: "scope of element",
                      type:        :string

      input "regexp", description: "value will be templatized only if it is satisfied to this regexp (for instance)",
                      type:        :string

      def perform
        raise_error_if_no_source_manifest
        ensure_yml_file_exist(self.target)
        # value_matcher = to_regexp(value)

        raise "scope must not match value wildcard" if scope.match(value)

        source_manifest.traverse do |node|
          if node.content.to_s.match(value)
            # match = node.content.to_s.match(value_matcher)[0]
            match = node.content.to_s.match(value)[0]
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

      def raise_if_no_source_manifest
        if self.source.nil? || !File.exist?(self.source)
          raise Manifest::FileNotFoundError.new("Source manifest does not exist: #{self.source.inspect}")
        end
      end

    end
  end
end
