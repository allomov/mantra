module Mantra
  class Manifest
    class RootElement < Element

      type :root

      def content=(content)
        @content = Element.create(content, self)
      end

      def path
        ""
      end

      def merge(element)
        raise merge_conflict_error unless self.can_merge?(element)
        self.content.merge(element.content)
      end

      def to_ruby_object
        self.content.to_ruby_object
      end

      def traverse(&block)
        self.content.traverse(&block)
      end

      def child
        self.content
      end

      def children
        self.content
      end

      def find_children_by_scope(scope)
        self.content.find_children_by_scope(scope)
      end

      def find(string_scope)
        scope = Scope.parse(string_scope)
        self.find_children_by_scope(scope)
      end

    end
  end
end
