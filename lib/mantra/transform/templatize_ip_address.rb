module Mantra
  class Transform
    class TemplatizeIpAddress < Transform
      type :"templatize-ip-address"
      include Mantra::Helpers::RegexpHelper

      description "Templatize ip addresses"

      input "source", description: "Source manifest with ceritificates, that will become a template",
                      type:        :file,
                      validate:    :file_exists

      input "target", description: "Target manifest with extracted ceritificates",
                      type:        :file

      input "value",  description: "value you want to templatize (wildcard is available, i.e. '*.domain.com')",
                      type:        :string

      input "quad",   description: "scope of element",
                      type:        :hash

      # quad: {number: 1}
      # quad: {range: "1-3"}

      def perform
        raise_error_if_no_source_manifest
        ensure_yml_file_exist(self.target)

        source_manifest.traverse do |node|
          if is_ip_address?(node.content)
            match = node.content.to_s.match(value_matcher)[0]
            begin_index   = node.content.to_s.index(match)
            end_index     = begin_index + match.size
            final_value   = merge_tool.templatize(node.content.to_s, scope, begin_index, end_index)
            node.content  = final_value
            scope_element = Manifest::Element.element_with_selector(scope, value)
            target_manifest.merge(scope_element)
          end
        end

        source_manifest.save
        target_manifest.save
      end

      def is_range?(value)
      end

      def is_ip_address?(value)
      end

      class QuadSplitter
        attr_accessor :start, :finish, :before, :after, :value
        def initialize(value, options)
          options[:range] = "#{options[:number]}-#{options[:number]}" if options[:number]
          first_quad_range_index, last_quad_range_index = *options[:range].split("-").map do |v|
            v.to_i - 1
          end
          quads = value.split(".")

          quads_before    = first_quad_range_index == 0 ? [] : quads[0..first_quad_range_index-1]
          extracted_quads = quads[first_quad_range_index..last_quad_range_index]
          quads_after     = last_quad_range_index == 3 ? [] : quads[last_quad_range_index+1..-1]

          self.before = quads_before.join(".")
          self.after  = quads_after.join(".")
          self.value  = extracted_quads.join(".")

          self.before = "#{self.before}." unless quads_before.empty?
          self.after  = ".#{self.after}"  unless quads_after.empty?

          self.start  = self.before.size
          self.finish = self.start + self.value.size
        end
      end

    end
  end
end
