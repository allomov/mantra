class Scope < String
end

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
          # template, values = if is_ip_address?(node.content)
          #   quad = QuadSplitter.new(node.content, quad)
          #   "(( #{templatize(quad.parts)} ))", quad.value
          # elsif is_network?(node.content)
          #   # node.content
          #   ip_address, network_prefix_size = *node.content.split("/")
          #   quad = QuadSplitter.new(ip_address, quad)
          #   quad.parts(templatize: false).push("/#{network_prefix_size}")
          #   "(( #{templatize(quad.parts).join(" ")} ))", quad.values
          # elsif is_ip_range?(node.content)
          #   ip_address1, ip_address2 = *node.content.split("-").map { |ip| ip.strip }
          #   quad1 = QuadSplitter.new(ip_address1, quad)
          #   quad2 = QuadSplitter.new(ip_address2, quad)
          #   (quad1.parts + quad2.parts).join(" ")
          #   if quad1.values != quad2.values
          #     raise ValidationError.new("quad values should be equal in range #{node.content}")
          #   end
          #   connector = [quad1.after, "-", quad2.before].select { |s| !s.empty? }.join("")
          #   template_elements = [quad1.before, Scope.new(scope), connector,
          #                        Scope.new(scope), quad2.after]
          #   "(( #{templatize(template_elements)} ))", quad1.value
          # end
          # unless template.nil?
          #   node.content = Element.create(template)
          #   scope_element = Manifest::Element.element_with_selector(scope, value)
          #   target_manifest.merge(scope_element)
          # end
        end

        source_manifest.save
        target_manifest.save
      end

      def ip_address_matcher
        "(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})"
      end

      def is_network?(value)
        !!value.to_s.match(/^#{ip_address_matcher}\s*-\s*#{ip_address_matcher}\/\d{1,2}$/)
      end

      def is_ip_range?(value)
        !!value.to_s.match(/^#{ip_address_matcher}\s*-\s*#{ip_address_matcher}$/)
      end

      def is_ip_address?(value)
        !!value.to_s.match(/^#{ip_address_matcher}$/)
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
        attr_accessor :start, :finish, :before, :after, :value, :parts
        def initialize(ip_address, options)
          quads = ip_address.split(".")
          # [{"number" => 3,    "scope"  => "meta.networks.cf.quad"},
          #  {"range" => "1-2", "scope"  => "meta.networks.prefix"}]
          quads_to_extract = options["quads"].map do |quad|
            if quad["number"]
              index = quad["number"].to_i - 1
              quad["range"] = (index..index)
            elsif quad["range"]
              index1, index2 = *quad["range"].split("-").map do |v|
                v.strip.to_i - 1
              end
              quad["range"] = (index1..index2)
            end
            quad
          end
          result = []
          quads.each_with_index do |q, current_quad_index|
            quad_to_extract = quads_to_extract.find do |quad|
              quad["range"].to_a.include?(current_quad_index)
            end
            if quad_to_extract.nil?
              result << "." if result.last.is_a?(Scope)
              result << q
              result << "." if current_quad_index < 3
            else
              if result.last != quad_to_extract["scope"]
                result << Scope.new(quad_to_extract["scope"])
              end
            end
          end
          @parts = result
        end
        def parts(options={templatize: true})
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