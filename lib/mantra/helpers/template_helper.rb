module Mantra
  module Helpers
    module TemplateHelper

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
      
    end
  end
end

