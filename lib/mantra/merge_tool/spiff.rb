module Mantra
  class MergeTool
    class Spiff < MergeTool
      type :spiff

      def templatize(string, scope, start, finish)
        first_part = string[0..start-1]
        value      = string[start..finish]
        last_part  = string[finish..-1]
        first_part = first_part[3..-1] if first_part.end_with?("(( ")
        last_part  = last_part[0..-4]  if last_part.end_with?(" ))")
        ["((", "\"#{first_part}\"", scope, "\"#{last_part}\"", "))"].select do |s|
          s != "\"\""
        end.join(" ")
      end

      def is_template?(string)
        !!string.match(/^\(\(.*\)\)$/)
      end

    end
  end
end
