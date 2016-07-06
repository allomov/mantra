module Mantra
  class Manifest
    class Element

      class MergeConflictError < Exception; end
      class UnknownScopeError  < Exception; end

      include Helpers::ObjectWithType
      include Helpers::RegexpHelper

      attr_accessor :content, :parent

      def self.create(content, parent = nil)
        return RootElement.new(content, parent) if parent.nil?
        case content
        when Element then Element.create(content.content, parent)
        when Array   then ArrayElement.new(content, parent)
        when Hash    then HashElement.new(content, parent)
        else LeafElement.new(content, parent)
        end
      end

      def initialize(content, parent)
        self.content = content
        self.parent  = parent
      end

      # this method mimics ruby Hash#fetch method
      def fetch(scope, &block)
        current_scope = Scope.parse(scope)
        element = self.root? ? self.content : self
        current_scope.filter(element, &block)
      end

      alias_method :select, :fetch

      def children
        raise "not implemented"
      end

      def content=(content)
        raise "#content=() method is not implemented"
      end

      def name
        raise "unknown name"
      end

      def find(string_scope)
        self.fetch(string_scope) do |element|
          return element.first
        end
      end

      def has_name?
        false
      end

      def has_equal_name?(element)
        false
      end

      %i(leaf hash array root).each do |type|
        define_method "#{type}?" do
          self.type == type
        end
      end

      def path
        case self.parent.type
        when :hash  then "#{self.parent.path}#{self.parent.parent.root? ? "" : "."}#{self.selector}"
        when :array then "#{self.parent.path}[#{self.selector}]"
        when :leaf  then raise "leaf can't be parent"
        end
      end

      def selector
        case self.parent.type
        when :array
          self.has_name? ? "name=#{self.name}" : ""
        when :hash
          self.parent.selector_for(self)
        when :root
          ""
        else
          raise "don't know how to build selector"
        end
      end

      def merge(element)
        raise "not implemented"
      end

      def to_ruby_object
        raise "not implemented"
      end

      def merge_conflict_error(element)
        object = element.respond_to?(:to_ruby_object) ? element.to_ruby_object : element.inspect
        MergeConflictError.new("merge conflicts: #{self.to_ruby_object} with #{object}")
      end

      def can_merge?(element)
        if element.respond_to?(:type)
          self.type == element.type
        else
          self.class == element.class
        end
      end

      def delete(selector)
        raise "not implemented"
      end

      def method_missing(method_name, *arguments, &block)
        if self.content.respond_to?(method_name)
          self.content.send(method_name, *arguments, &block)
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        self.content.respond_to?(method_name) || super
      end

      def traverse(&block)
        raise "not implemented"
      end

      def match_selector?(selector)
        selector.empty?
      end

      def path_exist?(path)
        !self.select(path).empty?
      end

      def add_node(selector, value)
        raise "not implemented"
      end

      def self.element_with_selector(selector, value)
        object_to_add = {}
        parts = selector.split(".")
        last_key = parts.pop
        last_node = parts.inject(object_to_add) do |h, part|
          h[part] = {}; h[part]
        end
        last_node[last_key] = value
        Element.create(object_to_add)
      end

      def split_selector(selector, matcher_regex)
        matcher = selector.match(matcher_regex)
        raise UnknownScopeError.new("Unknown selector: #{selector}") if matcher.nil?
        head_selector = matcher[1]
        tail_selector = matcher[2]
        return head_selector, tail_selector
      end

      def array_selector?(selector)
        !!selector.match(/\[(.+\=.+|\d+)?\].*/)
      end

      def hash_selector?(selector)
        !!selector.match(/[a-z0-9]+/)
      end

    end
  end
end
