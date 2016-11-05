require "json"

module SecureConf
  module Serializer
    module JSON
      def self.dump(obj)
        ::JSON.dump(obj)
      end

      def self.load(str)
        ::JSON.load(str)
      end
    end
  end
end
