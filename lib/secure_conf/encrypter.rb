require 'openssl'
require 'base64'
require 'secure_conf/openssh'

module SecureConf
  class Encrypter
    def initialize(pkey=nil, pass=nil)
      pkey ||= File.open(File.expand_path("~/.ssh/id_rsa"), "r") {|f| f.read }
      self.pkey = [pkey, pass]
    end

    def pkey=(pk)
      pk, pass = [pk].flatten

      case pk
      when OpenSSL::PKey::RSA
        # OpenSSL private key object
        @pkey = pk
      when OpenSSH::PKey
        # OpenSSH private key object
        @pkey = pk.to_openssl
      when String
        pk = pk.strip
        if pk.start_with?("-----BEGIN OPENSSH PRIVATE KEY-----") && pk.end_with?("-----END OPENSSH PRIVATE KEY-----")
          # OpenSSH private pem string
          @pkey = OpenSSH::PKey.new(pk).to_openssl
        else
          # OpenSSL private pem string
          @pkey = OpenSSL::PKey::RSA.new(pk, pass)
        end
      when Integer
        # generate
        @pkey = OpenSSL::PKey::RSA.new(pk)
      end
    end

    def encrypt(str)
      Base64.strict_encode64(@pkey.public_encrypt(str))
    end

    def decrypt(str)
      @pkey.private_decrypt(Base64.strict_decode64(str))
    end
  end
end
