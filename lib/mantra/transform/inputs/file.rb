module Mantra
  class Transform
    class Input
      class File < Input
        type :file

        def validate_file_exists(value, name)
          unless ::File.exist?(value)
            raise ValidationError.new("File does not exist: #{value}")
          end
        end

      end      
    end
  end
end
