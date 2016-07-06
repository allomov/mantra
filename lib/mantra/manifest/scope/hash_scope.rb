module Mantra
  class Manifest
    class Scope
      class HashScope < Scope

        type :hash

        # returns array of children that matches this scope
        def _filter(element)
          scope_regexp = to_regexp(scope)
          element.content.each_pair.map do |pair|
            key, value = *pair
            key.match(scope_regexp) ? value : nil
          end.compact
        end

      end
    end
  end
end