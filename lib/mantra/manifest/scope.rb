module Mantra
  class Manifest
    class Scope

      class ScopeParseError < Exception; end
      
      include Helpers::ObjectWithType
      include Helpers::RegexpHelper

      def self.parse(scope_or_string)
        return scope_or_string if scope_or_string.is_a?(Scope)
        parse_selector(scope_or_string)
      end

      HASH_SELECTOR_REGEXP  = /^([a-zA-Z0-9\_\-\=\*]+)\.?(.*)$/
      ARRAY_SELECTOR_REGEXP = /^\[([a-zA-Z0-9\:\_\-\=\*]*)\]\.?(.*)$/

      def self.parse_selector(selector)
        case selector
        when HASH_SELECTOR_REGEXP
          head_selector, tail_selector = split_selector(selector, HASH_SELECTOR_REGEXP)
          HashScope.new(scope: head_selector, next: parse_selector(tail_selector))
        when ARRAY_SELECTOR_REGEXP
          head_selector, tail_selector = split_selector(selector, ARRAY_SELECTOR_REGEXP)
          ArrayScope.new(scope: head_selector, next: parse_selector(tail_selector))
        when ""
          EmptyScope.new()
        else
          raise_parse_error(selector)
        end
      end

      def self.split_selector(selector, matcher_regex)
        matcher = selector.match(matcher_regex)
        raise_parse_error(selector) if matcher.nil?
        head_selector = matcher[1]
        tail_selector = matcher[2]
        return head_selector, tail_selector
      end

      def self.raise_parse_error(selector)
        raise ScopeParseError.new("Can't parse selector: #{selector}")
      end

      attr_accessor :scope, :next

      def initialize(options={})
        self.scope, self.next = options[:scope], options[:next]
      end

      def last?
        self.is_a?(EmptyScope)
      end

      alias_method :tail, :next

      def match?(manifest_element)
        raise "not implemented"
      end

      def filter(element, &block)
        return [] if !has_same_type?(element)
        matched_elements = _filter(element)
        if self.last?
          block.call(matched_elements) if block_given?
          matched_elements
        else
          matched_elements.map do |e|
            self.next.filter(e)
          end.compact.flatten
        end
      end

      def has_same_type?(element)
        raise element.inspect if element.is_a?(Array)
        self.type == element.type
      end

      def _filter(element)
        raise "not implemented"
      end

      def to_a
        [self, self.tail.to_a].flatten
      end

    end
  end
end

require "mantra/manifest/scope/array_scope"
require "mantra/manifest/scope/empty_scope"
# require "mantra/manifest/scope/leaf_scope"
require "mantra/manifest/scope/hash_scope"
