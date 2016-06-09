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

      def merge(element)
        raise merge_conflict_error(element) unless self.can_merge?(element)
        self.content.merge!(element.content) do |_, self_element, element_to_merge|
          self_element.merge(element_to_merge)
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

      def select(selector)
        return self if selector.empty?
        head_selector, tail_selector = split_selector(selector, /^([a-zA-Z0-9\_\-\=\*]*)\.?(.*)$/)
        key_matcher = convert_to_regex(head_selector)
        self.content.each_pair.map do |pair|
          key, value = *pair
          value.select(tail_selector) if key.match(key_matcher)
        end.compact.flatten
      end

      def match_selector?(selector)
        return true if selector.empty?
        key, value    = *selector.split("=")
        key_matcher   = convert_to_regex(key)
        value_matcher = convert_to_regex(value)
        matched_element = self.content.each_pair.find do |pair|
          k, v = *pair
          (k.match(key_matcher) && v.leaf? && v.content.to_s.match(value_matcher))
        end
        !!matched_element
      end

      def traverse(&block)
        self.content.each_value do |value|
          value.traverse(&block)
        end
      end

    end
  end
end
