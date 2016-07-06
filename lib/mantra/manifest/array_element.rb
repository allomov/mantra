module Mantra
  class Manifest
    class ArrayElement < Element

      type :array

      def content=(content)
        @content = content.map do |item|
          Element.create(item, self)
        end
      end

      def merge(element)
        raise merge_conflict_error(element) unless self.can_merge?(element)
        elements_to_add = element.content.dup
        merge_by_name(elements_to_add)
        merge_by_value(elements_to_add)
        self.content.concat(elements_to_add)
        self
      end

      def find_children_by_scope(scope)
        return [] unless scope.array?
        self.content.map do |element|
          if scope.match?(element)
            if scope.has_next?
              element.find_children_by_scope(scope.next)
            else
              element
            end
          end
        end.flatten.compact
      end

      def each(path, &block)
        elements = select(path)
        elements.each(&block)
      end

      def selector_for(element)
        self.content.index(element).to_s
      end

      def merge_by_value(elements)
        self.content.each do |self_element|
          element_with_the_same_value = elements.find do |element_to_add|
            self_element.content == element_to_add.content
          end
          unless element_with_the_same_value.nil?
            self_element.merge(element_with_the_same_value)
            elements.delete(element_with_the_same_value)
          end
        end
      end

      def children
        self.content
      end

      def merge_by_name(elements)
        self.content.each do |self_element|
          element_with_the_same_name = elements.find do |element_to_add|
            self_element.has_equal_name?(element_to_add)
          end
          unless element_with_the_same_name.nil?
            self_element.merge(element_with_the_same_name)
            elements.delete(element_with_the_same_name)
          end
        end
      end

      def to_ruby_object
        self.content.map { |element| element.to_ruby_object }
      end

      def traverse(&block)
        self.content.each do |value|
          value.traverse(&block)
        end
      end

      def add_node(selector, value)
        # return self.content << Element.create(value).child if element_with_selector()
        head_selector, tail_selector = split_selector(selector, /^\[([a-zA-Z0-9\_\-\=\*]*)\]\.?(.*)$/)
        self.content.each do |element|
          element.add_node(tail_selector, value) if element.match_selector?(head_selector)
        end
      end

    end
  end
end
