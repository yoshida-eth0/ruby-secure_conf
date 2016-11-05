module SecureConf
  module Serializer
    module Marshal
      def self.dump(obj)
        ::Marshal.dump(obj)
      end

      def self.load(str)
        ::Marshal.load(str)
      end
    end
  end
end
