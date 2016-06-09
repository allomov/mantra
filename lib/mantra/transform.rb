module Mantra
  class Transform
    include Helpers::ObjectWithType



  end
end

require "mantra/transforms/extract_section"
require "mantra/transforms/extract_certificates"
require "mantra/transforms/extract_certificates_to_file"
require "mantra/transforms/templatize_value"
