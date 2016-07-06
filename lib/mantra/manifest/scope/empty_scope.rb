module Mantra
  class Manifest
    class Scope
      class EmptyScope < Scope

        type :empty

        # returns array of children that matches this scope
        def _filter(element)
          [element]
        end

        def last?
          true
        end

        def has_same_type?(element)
          true
        end

      end
    end
  end
end