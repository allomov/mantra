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

      def select(selector)
        self.content.select(selector)
      end

      def traverse(&block)
        self.content.traverse(&block)
      end

    end
  end
end
