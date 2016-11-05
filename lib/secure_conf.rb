require "secure_conf/version"
require "secure_conf/config"
require "secure_conf/encrypter"
require "secure_conf/serializer"
require "secure_conf/storage"

module SecureConf
  class << self
    def default
      @@default ||= SecureConf::Encrypter.new
    end

    def default=(encrypter)
      @@default = encrypter
    end

    def method_missing(method, *args)
      default.send(method, *args)
    end
  end
end
