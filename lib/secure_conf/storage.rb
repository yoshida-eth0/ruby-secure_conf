require "secure_conf/storage/yaml"

module SecureConf
  module Storage
    def self.fetch(path)
      ext = File.extname(path).sub(".", "").capitalize
      const_get(ext)
    end
  end
end
