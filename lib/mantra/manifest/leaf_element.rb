module Mantra
  class Manifest
    class LeafElement < Element

      type :leaf

      def content=(content)
        @content = content
      end

      def merge(element, options={})
        raise merge_conflict_error(element) unless self.can_merge?(element)
        if !options[:force]
          raise MergeConflictError.new("value conflict detected: #{self.content} != #{element.content}") if self.content != element.content
        end
        self
      end

      def to_ruby_object
        self.content
      end

      def traverse(&block)
        block.call(self)
      end

      def add_node(selector, value)
        raise UnknownScopeError.new("Can't add nodes to leaf")  unless selector.empty?
        raise MergeConflictError.new("Leaf already exists with another value: #{self.content} != #{value}") unless self.content != value
      end

      def children
        []
      end

    end
  end
end
