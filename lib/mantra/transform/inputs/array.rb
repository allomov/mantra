module Mantra
  class Transform
    class Input
      class ArrayInput < Input
        type :array

        def validate_file_exists(value, name)
          unless File.exist?(value)
            raise ValidationError.new("File does not exist: #{value}")
          end
        end

      end
    end
  end
end
