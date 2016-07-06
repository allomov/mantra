module Mantra
  class Manifest
    class Scope
      class ArrayScope < Scope
        class UnknownFunction < Exception; end

        type :array

        # returns array of children that are 
        def _filter(element)
          case scope
          when /^\d+$/
            index = scope.to_i
            [element.content[index]]
          when /^.+\=.+$/
            key_wildcard, value_wildcard = scope.split("=")
            key_matcher, value_matcher = to_regexp(key_wildcard), to_regexp(value_wildcard)
            element.content.select { |e| e.hash? }.select do |e|
              e.each_pair.any? do |pair|
                k, v = *pair
                k.match(key_matcher) && v.match(value_matcher)
              end
            end
          when /^\:\:.+$/
            function_name = self.scope[2..-1]
            if !allowed_function_names.include?(function_name)
              raise ScopeParseError.new("Unknown function: #{function_name}")
            end
            self.send(function_name, element)
          when ""
            element.content
          else
            raise ScopeParseError.new("Don't know how to apply scope to array " +
                                      "(scope: #{self.scope.inspect}, array: #{element.to_ruby_object.inspect})")
          end
        end

        def allowed_function_names
          %w(last first)
        end

        def last(element)
          [element.content.last]
        end

        def first(element)
          [element.content.first]
        end

      end
    end
  end
end