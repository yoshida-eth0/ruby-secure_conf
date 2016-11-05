require "yaml"

module SecureConf
  module Storage
    def self.fetch(path)
      ext = File.extname(path).sub(".", "").capitalize
      const_get(ext)
    end

    module Yaml
      def self.load(path)
        if File.file?(path)
          YAML.load_file(path)
        else
          {}
        end
      end

      def self.save(path, obj)
        h = {}
        h.replace(obj)
        YAML.dump(h, File.open(path, "w"))
      end
    end
    Yml = Yaml
  end
end
