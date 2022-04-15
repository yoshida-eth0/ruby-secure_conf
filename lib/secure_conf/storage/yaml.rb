require "yaml"

module SecureConf
  module Storage
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
        File.open(path, "w") {|f|
          YAML.dump(h, f)
        }
      end
    end
    Yml = Yaml
  end
end
