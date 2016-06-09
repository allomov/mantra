require "tempfile"

module Mantra
  class Certificates
    class Cortege

      attr_accessor :public_key, :private_key, :certificate
      def initialize(options)
        self.public_key  = options[:public_key]
        self.private_key = options[:private_key]
        self.certificate = options[:certificate]
      end

      def matches?
        if self.has_private_key? && self.has_certificate?
          return private_key_matches_certificate?
        elsif self.has_private_key? && self.has_public_key?
          return private_key_matches_public_key?
        else
          puts "Warning: don't know what to do with following certificate cortege #{self.inspect}"
          return false
        end
      end

      def has_certificate?
        !!self.certificate
      end

      def has_public_key?
        !!self.public_key
      end

      def has_private_key?
        !!self.private_key
      end

      private

      # https://www.digitalocean.com/community/tutorials/openssl-essentials-working-with-ssl-certificates-private-keys-and-csrs
      # https://www.sslshopper.com/article-most-common-openssl-commands.html
      # TODO: find out if there are ruby wrappers for this calls
      def private_key_matches_certificate?
        private_key_file_path = temp_file_wrapper(self.private_key.value, "domain.key")
        certificate_file_path = temp_file_wrapper(self.certificate.value, "domain.crt")
        private_key_md5 = `openssl rsa -noout -modulus -in #{private_key_file_path} 2> /dev/null | openssl md5`
        certificate_md5 = `openssl x509 -noout -modulus -in #{certificate_file_path} 2> /dev/null | openssl md5`
        private_key_md5 == certificate_md5
      end

      def private_key_matches_public_key?
        private_key_file_path  = temp_file_wrapper(self.private_key.value, "domain.key")
        private_key_public_key = `openssl rsa -in #{private_key_file_path} -pubout 2> /dev/null`
        private_key_public_key.strip == self.public_key.value
      end

      def temp_file_wrapper(string, filename)
        file = Tempfile.new(filename)
        file.write(string)
        file.close
        file.path
      end
    end
  end
end
