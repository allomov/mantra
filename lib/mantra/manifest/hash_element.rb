module Mantra
  class Manifest
    class HashElement < Element
      type :hash

      def content=(content) # content is hash
        @content = content.to_a.inject({}) do |result, pair|
          key, value = *pair
          result[key] = Element.create(value, self)
          result
        end
      end

      def merge(element, options={})
        element = escape_root(element)
        raise merge_conflict_error(element) unless self.can_merge?(element)
        self.content.merge!(element.content) do |_, self_element, element_to_merge|
          self_element.merge(element_to_merge, options)
        end
        self
      end

      def to_ruby_object
        self.content.to_a.inject({}) do |result, pair|
          key, element = *pair
          result[key] = element.to_ruby_object
          result
        end
      end

      def has_equal_name?(element)
        self.has_name? && element.has_name? && self.name == element.name
      end

      def has_name?
        self.content.has_key?("name")
      end

      def children
        self.content.values
      end

      def name
        raise "name should be a value, not node" if !self.content["name"].leaf?
        self.content["name"].content || raise("no name for #{self.inspect}")
      end

      def selector_for(element)
        self.content.each_pair do |key, value|
          return key if value == element
        end
        raise "can't find key for object: #{element.to_ruby_object.inspect}"
      end

      def method_missing(method_name, *arguments, &block)
        if self.content.has_key?(method_name.to_s) && arguments.empty?
          self.content[method_name.to_s]
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        self.content.has_key?(method_name.to_s) || super
      end

      def traverse(&block)
        self.content.each_value do |value|
          value.traverse(&block)
        end
      end

      def find_children_by_scope(scope)
        return [] unless scope.hash?
        self.content.each_pair.map do |pair|
          key, value = *pair
          if scope.match?(key, value)
            if scope.has_next?
              element.find_children_by_scope(scope.next)
            else
              element
            end
          end
        end.flatten.compact
      end

    end
  end
end
