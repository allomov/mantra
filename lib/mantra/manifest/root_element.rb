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

      def child
        self.content
      end

      def add_node(selector, value)
        # value_element = Element.create(value).child
        self.child.add_node(selector, value)
        # parts = new_path.split(".")
        # latest_existing_node = find_latest_existing_node(new_path)
        # first_key = parts.shift
        # last_key = parts.pop
        # object_to_add = {}
        # last_node = parts.inject(object_to_add) { |h, part| h[part] = {}; h[part]  }
        # if last_key.nil?
        #   object_to_add = value
        # else
        #   last_node[last_key] = value
        # end
        # latest_existing_node[first_key] = object_to_add
      end

    end
  end
end
