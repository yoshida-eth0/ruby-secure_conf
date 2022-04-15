require 'stringio'
require 'base64'
require 'singleton'
require 'openssl'

module SecureConf
  module OpenSSH
    class PKey

      def initialize(source)
        if String===source
          # pem string
          @h = parse_pem(source)

        elsif IO===source || source.respond_to?(:read)
          # pem io
          source = source.read
          @h = parse_pem(source)

        elsif source.respond_to?(:to_der)
          # call to_der method
          der = source.to_der
          @h = parse_der(der)

        else
          # other
          raise ArgumentError, "unsupported argument type: #{source.class.name}"
        end
      end

      def parse_pem(pem)
        pem = pem.strip
        if !pem.start_with?("-----BEGIN OPENSSH PRIVATE KEY-----") || !pem.end_with?("-----END OPENSSH PRIVATE KEY-----")
          raise FormatError, "invalid pem string"
        end

        pem = pem.gsub(/-----(?:BEGIN|END) OPENSSH PRIVATE KEY-----/, "").gsub(/[\r\n]/, "")
        der = Base64::strict_decode64(pem)
        parse_der(der)
      end

      # sshkey_private_to_blob2
      # https://github.com/openssh/openssh-portable/blob/master/sshkey.c#L3910
      def parse_der(der)
        bio = StringIO.new(der, "rb")
        h = {}

        # header
        h[:header] = bio.read(15)
        if h[:header]!="openssh-key-v1\0"
          raise FormatError, "openssh header not found"
        end

        # ciphername
        length = bio.read(4).unpack("N")[0]
        h[:ciphername] = bio.read(length)
        if h[:ciphername]!="none"
          raise FormatError, "ciphername is not 'none': #{h[:ciphername]}"
        end

        # kdfname
        length = bio.read(4).unpack("N")[0]
        h[:kdfname] = bio.read(length)
        if h[:kdfname]!="none"
          raise FormatError, "kdfname is not 'none': #{h[:kdfname]}"
        end

        # kdf
        length = bio.read(4).unpack("N")[0]
        h[:kdf] = bio.read(length)
        if h[:kdf]!=""
          raise FormatError, "kdf is not empty: #{h[:kdfname]}"
        end

        # number of keys
        h[:keys_num] = bio.read(4).unpack("N")[0]
        if h[:keys_num]!=1
          raise FormatError, "number of keys is not 1: #{h[:keys_num]}"
        end

        # public key
        length = bio.read(4).unpack("N")[0]
        publickey = bio.read(length)
        h[:publickey] = parse_der_publickey(publickey)

        # rnd+prv+comment+pad
        length = bio.read(4).unpack("N")[0]
        privatekey = bio.read(length)
        h[:privatekey] = parse_der_privatekey(privatekey)

        # check eof
        if !bio.eof?
          raise FormatError, "no eof"
        end

        h
      end

      # to_blob_buf
      # https://github.com/openssh/openssh-portable/blob/master/sshkey.c#L828
      def parse_der_publickey(publickey)
        bio = StringIO.new(publickey, "rb")
        h = {}

        # keytype
        length = bio.read(4).unpack("N")[0]
        h[:keytype] = bio.read(length)

        # content
        kt = Keytype.fetch(h[:keytype])
        if !kt
          raise UnsupportedError, "unsupported keytype: #{h[:keytype]}"
        end
        kt.parse_der_public_key_contents(h, bio)

        # check eof
        if !bio.eof?
          raise FormatError, "publickey no eof"
        end

        h
      end

      # sshkey_private_serialize_opt
      # https://github.com/openssh/openssh-portable/blob/master/sshkey.c#L3230
      def parse_der_privatekey(privatekey)
        bio = StringIO.new(privatekey, "rb")
        h = {}

        # checksum
        h[:checksum] = bio.read(8).unpack("NN")

        # keytype
        length = bio.read(4).unpack("N")[0]
        h[:keytype] = bio.read(length)

        # content
        kt = Keytype.fetch(h[:keytype])
        if !kt
          raise UnsupportedError, "unsupported keytype: #{h[:keytype]}"
        end
        kt.parse_der_private_key_contents(h, bio)

        # comment
        length = bio.read(4).unpack("N")[0]
        h[:comment] = bio.read(length)

        # padding
        h[:padding] = bio.read

        # check eof
        if !bio.eof?
          raise FormatError, "privatekey no eof"
        end

        h
      end

      def keytype
        Keytype.fetch(@h[:privatekey][:keytype])
      end

      def to_openssl
        keytype.to_openssl(@h)
      end

      def to_openssl_pem
        keytype.to_openssl_pem(@h)
      end

      def to_openssl_der
        keytype.to_openssl_der(@h)
      end
    end

    module Keytype
      module Base
        def support?(keytype)
          raise Error, "not implemented error: #{self.class.name}.support?(keytype)"
        end

        def parse_der_public_key_contents(h, bio)
          raise Error, "not implemented error: #{self.class.name}.parse_der_public_key_contents(h, bio)"
        end

        def parse_der_private_key_contents(h, bio)
          raise Error, "not implemented error: #{self.class.name}.parse_der_private_key_contents(h, bio)"
        end

        def to_openssl(h)
          raise Error, "not implemented error: #{self.class.name}.to_openssl(h)"
        end

        def to_openssl_pem(h)
          raise Error, "not implemented error: #{self.class.name}.to_openssl_pem(h)"
        end

        def to_openssl_der(h)
          raise Error, "not implemented error: #{self.class.name}.to_openssl_der(h)"
        end
      end

      class RSA
        include Singleton
        include Base

        def support?(keytype)
          keytype=="ssh-rsa"
        end

        def parse_der_public_key_contents(h, bio)
          # e pub0
          length = bio.read(4).unpack("N")[0]
          h[:e] = bio.read(length)

          # n pub1
          length = bio.read(4).unpack("N")[0]
          h[:n] = bio.read(length)
        end

        def parse_der_private_key_contents(h, bio)
          # n pub0
          length = bio.read(4).unpack("N")[0]
          h[:n] = bio.read(length)

          # e pub1
          length = bio.read(4).unpack("N")[0]
          h[:e] = bio.read(length)

          # d pri0
          length = bio.read(4).unpack("N")[0]
          h[:d] = bio.read(length)

          # iqmp
          length = bio.read(4).unpack("N")[0]
          h[:iqmp] = bio.read(length)

          # p
          length = bio.read(4).unpack("N")[0]
          h[:p] = bio.read(length)

          # q
          length = bio.read(4).unpack("N")[0]
          h[:q] = bio.read(length)
        end

        def to_openssl(h)
          pem = to_openssl_pem(h)
          OpenSSL::PKey::RSA.new(pem)
        end

        def to_openssl_pem(h)
          der = to_openssl_der(h)
          b64 = Base64::strict_encode64(der)
          lines = b64.scan(/.{1,64}/)

          [
            "-----BEGIN RSA PRIVATE KEY-----",
            lines,
            "-----END RSA PRIVATE KEY-----",
          ].flatten.join("\n")
        end

        def to_openssl_der(h)
          d = h[:privatekey][:d].unpack("H*")[0].to_i(16)
          p = h[:privatekey][:p].unpack("H*")[0].to_i(16)
          q = h[:privatekey][:q].unpack("H*")[0].to_i(16)

          exponent1 = d % (p - 1)
          exponent2 = d % (q - 1)

          OpenSSL::ASN1::Sequence.new([
            OpenSSL::ASN1::Integer.new(0),
            OpenSSL::ASN1::Integer.new(h[:privatekey][:n].unpack("H*")[0].to_i(16)),
            OpenSSL::ASN1::Integer.new(h[:privatekey][:e].unpack("H*")[0].to_i(16)),
            OpenSSL::ASN1::Integer.new(h[:privatekey][:d].unpack("H*")[0].to_i(16)),
            OpenSSL::ASN1::Integer.new(p),
            OpenSSL::ASN1::Integer.new(q),
            OpenSSL::ASN1::Integer.new(exponent1),
            OpenSSL::ASN1::Integer.new(exponent2),
            OpenSSL::ASN1::Integer.new(h[:privatekey][:iqmp].unpack("H*")[0].to_i(16)),
          ]).to_der
        end
      end

      KEYTYPES = [RSA.instance]

      def self.fetch(keytype)
        KEYTYPES.find {|kt| kt.support?(keytype)}
      end
    end

    class Error < StandardError
    end

    class FormatError < Error
    end

    class UnsupportedError < Error
    end
  end
end
