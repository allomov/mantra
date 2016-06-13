module Mantra
  class Manifest
    class LeafElement < Element

      type :leaf

      def content=(content)
        @content = content
      end

      def merge(element)
        raise merge_conflict_error(element) unless self.can_merge?(element)
        raise MergeConflictError.new("value conflict detected: #{self.content} != #{element.content}") if self.content != element.content
        self
      end

      def to_ruby_object
        self.content
      end

      def select(selector)
        # raise UnknownScopeError.new("leaf can't handle selector") unless selector.empty?
        selector.empty? ? self : nil
      end

      def traverse(&block)
        block.call(self)
      end

      def add_node(selector, value)
        raise UnknownScopeError.new("Can't add nodes to leaf")  unless selector.empty?
        raise MergeConflictError.new("Leaf already exists with another value: #{self.content} != #{value}") unless self.content != value
      end

    end
  end
end
