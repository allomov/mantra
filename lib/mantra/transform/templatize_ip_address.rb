module Mantra
  class Transform
    class TemplatizeIpAddress < Transform
      type :"templatize-ip-address"
      include Mantra::Helpers::RegexpHelper
      include Mantra::Helpers::TemplateHelper

      description "Templatize ip addresses"

      input "source", description: "Source manifest with ceritificates, that will become a template",
        type:        :file,
        validate:    :file_exists

      input "target", description: "Target manifest with extracted ceritificates",
        type:        :file

      # input "value",  description: "value you want to templatize (wildcard is available, i.e. '*.domain.com')",
      #                 type:        :string

      input "quads",   description: "quad that is going to be extracted",
        type:        :array


      def perform
        raise_error_if_no_source_manifest
        ensure_yml_file_exist(self.target)

        source_manifest.traverse do |node|
          template, values = if is_ip_address?(node.content)
            splitter = QuadSplitter.new(node.content, quads)
            ["(( #{splitter.parts(templatize: true).join(" ")} ))", splitter.values]
          elsif is_network_range?(node.content)
            ip_address, network_prefix_size = *node.content.split("/")
            puts "NETWORK RANGE! #{[ip_address, network_prefix_size].inspect}"
            splitter = QuadSplitter.new(ip_address, quads)
            network_range_parts = splitter.parts + ["/#{network_prefix_size}"]
            # puts "PARTS! #{network_range_parts.inspect}"
            resulting_template = "(( #{templatize(network_range_parts).join(" ")} ))"
            [resulting_template, splitter.values]
          elsif is_ip_range?(node.content)
            ip_address1, ip_address2 = *node.content.split("-").map { |ip| ip.strip }
            splitter1 = QuadSplitter.new(ip_address1, quads)
            splitter2 = QuadSplitter.new(ip_address2, quads)
            result = templatize(splitter1.parts + ["-"] + splitter2.parts)
            ["(( #{result.join(" ")} ))", splitter1.values]
          end
          unless template.nil?
            puts template.inspect if node.content == "192.168.3.0/24"
            raise UnknownScopeError.new("Can't templatize non leaf ip address") unless node.leaf?
            node.content = template
            values.each_pair do |scope, value|
              scope_element = Manifest::Element.element_with_selector(scope, value)
              target_manifest.merge(scope_element)
            end
          end
        end

        source_manifest.save
        target_manifest.save
      end

      def ip_address_matcher
        "(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})"
      end

      def is_network_range?(value)
        !!value.to_s.match(/^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})\/\d{1,2}$/)
      end

      def is_ip_range?(value)
        !!value.to_s.match(/^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})\s*-\s*(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/)
      end

      def is_ip_address?(value)
        !!value.to_s.match(/^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/)
      end

      def templatize(parts)
        merged_parts = [parts.shift]
        parts.each do |p|
          if !p.is_a?(Scope) && !merged_parts.last.is_a?(Scope)
            merged_parts.last.concat(p)
          else
            merged_parts << p
          end
        end
        merged_parts.select { |p| !p.empty? }.map do |p|
          p.is_a?(Scope) ? p : "\"#{p}\""
        end
      end

      class QuadSplitter
        include Mantra::Helpers::TemplateHelper
        attr_accessor :values, :parts
        def initialize(ip_address, template_quads)
          quads = ip_address.split(".")
          quads_to_extract = template_quads.map do |quad|
            if quad["number"]
              index = quad["number"].to_i - 1
              quad["range_object"] = (index..index)
            elsif quad["range"]
              index1, index2 = *quad["range"].split("-").map do |v|
                v.strip.to_i - 1
              end
              quad["range_object"] = (index1..index2)
            end
            quad
          end
          @parts = []
          @values = quads_to_extract.inject({}) { |hash, quad| hash[quad["scope"]] = []; hash }
          quads.each_with_index do |current_quad, current_quad_index|
            quad_to_extract = quads_to_extract.find do |quad|
              quad["range_object"].to_a.include?(current_quad_index)
            end
            if quad_to_extract.nil?
              @parts << "." if @parts.last.is_a?(Scope)
              @parts << current_quad
              @parts << "." if current_quad_index < 3
            else
              @values[quad_to_extract["scope"]] << current_quad
              if @parts.last != quad_to_extract["scope"]
                @parts << "." if @parts.last.is_a?(Scope)
                @parts << Scope.new(quad_to_extract["scope"])
              end
            end
          end

          @values.each_pair do |key, value|
            @values[key] = value.join(".")
          end
        end
        def parts(options={templatize: false})
          if options[:templatize]
            templatize(@parts)
          else
            @parts
          end
        end
      end

    end
  end
end
