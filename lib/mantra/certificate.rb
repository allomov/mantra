module Mantra
  module Certificate
    class DigitalCertificate
      TEMPLATE_MESSAGE = "Difital Certificate from file:"
      attr_accessor :path, :type, :value
      def initialize(options)
        self.path  = options[:path]
        self.type  = options[:type].strip
        self.value = options[:value].strip
      end

      def private_key?
        self.type.include? "PRIVATE KEY"
      end

      def public_key?
        self.type == "PUBLIC KEY"
      end

      def certificate?
        self.type == "CERTIFICATE"
      end

      def scope
        self.path.to_scope
      end

    end
  end
end

require "mantra/certificates/string_ext"
require "mantra/certificates/cortege"
require "mantra/certificates/group"
# require "mantra/certificates"
