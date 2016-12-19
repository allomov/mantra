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
        raise merge_conflict_error(element) unless self.can_merge?(element)
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

    end
  end
end
