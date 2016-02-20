require 'openssl'

module Ipizza
  module Config
    class Bank
      attr_accessor :bank_snd_id, :snd_id, :callback_url, :payment_url, :private_key_secret
      attr_reader :certificate, :private_key
      attr_writer :mobile_payment_url, :authentication_url, :return_url, :cancel_url

      def initialize(params = {})
        params.each do |key, value|
          begin
            send("#{key}=", value)
          rescue NoMethodError
            raise ConfigurationError.new("Invalid configuration parameter '#{key}'")
          end
        end
      end

      def mobile_payment_url
        @mobile_payment_url || @payment_url
      end

      def authentication_url
        @authentication_url || @payment_url
      end

      def return_url
        @return_url || callback_url
      end

      def cancel_url
        @cancel_url || callback_url
      end

      def private_key_path=(file_path)
        self.private_key_data = load_file(file_path)
      end

      def certificate_path=(file_path)
        self.certificate_data = load_file(file_path)
      end

      def private_key_data=(data)
        @private_key = OpenSSL::PKey::RSA.new(data, @private_key_secret)
      end

      def certificate_data=(data)
        @certificate = OpenSSL::X509::Certificate.new(data)
      end

      def public_key
        @certificate.public_key
      end


      private
      def load_file(file_path)
        unless File.exist?(file_path)
          file_path = File.expand_path(File.join(Ipizza::Config.certs_root, file_path))
        end

        unless File.exist?(file_path)
          raise ConfigurationError.new("Certificate / Private key file '#{file_path}' does not exist")
        end

        File.read(file_path)
      end
    end
  end
end
