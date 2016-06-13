class IpAddressTemplate
  class Scope < String
    attr_accessor :scope, :value
    def initialize(options)
      @value = options[:value]
      @scope = options[:scope]
      super(options[:scope])
    end
    def is_scope?
      true
    end
  end

  class Value < String
    def is_scope?
      false
    end
  end

  attr_accessor :quads
  def initialize(ip_address)
    @quads = ip_address.split(".").map { |q| Value.new(q) }
  end
  def replace_with_scope(range, scope)
    range.to_a.each do |i|
      @quads[i] = Scope.new(scope: scope, value: @quads[i])
    end
  end
  def parts
    result = [@quads.first]
    @quads[1..-1].each do |q|
      if q.is_scope? && result.last.is_scope? && q.scope == result.last.scope
        result.last.value = [result.last.value, q.value].join(".")
      else
        result << Value.new(".") << q
      end
    end
    result
  end
end

module Mantra
  module Helpers
    module TemplateHelper

      def is_scope?(v)
        v.respond_to?(:is_scope?) && v.is_scope?
      end

      def templatize(parts)
        merged_parts = [parts.shift]
        parts.each do |p|
          if !is_scope?(p) && !is_scope?(merged_parts.last)
            merged_parts.last.concat(p)
          else
            merged_parts << p
          end
        end
        merged_parts.select { |p| !p.empty? }.map do |p|
          is_scope?(p) ? p : "\"#{p}\""
        end
      end

    end
  end
end
