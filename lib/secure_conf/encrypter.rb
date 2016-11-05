require 'openssl'
require 'base64'

module SecureConf
  class Encrypter
    def initialize(pkey=nil, pass=nil)
      pkey ||= "~/.ssh/id_rsa"
      self.pkey = [pkey, pass]
    end

    def pkey=(pk)
      pk, pass = [pk].flatten

      case pk
      when OpenSSL::PKey::RSA
        @pkey = pk
      when String
        pk2 = File.expand_path(pk)
        if File.file?(pk2) && File.readable?(pk2)
          pk = File.read(pk2)
        end

        @pkey = OpenSSL::PKey::RSA.new(pk, pass)
      when Integer
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
