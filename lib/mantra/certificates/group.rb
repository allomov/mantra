require "forwardable"

# this class acts as it was simple DigitalCertificate
module Mantra
  class Certificates
    class Group
      extend Forwardable

      attr_accessor :certificates
      alias_method :collection, :certificates

      def_delegators :@certificates, :sample
      def_delegators :sample, :certificate?, :public_key?, :private_key?, :value


      def initialize(certificate_list)
        self.certificates = certificate_list
      end

      def private_keys
        self.certificates.select { |c| c.private_key? }
      end

    end
  end
end
