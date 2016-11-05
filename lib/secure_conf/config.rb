module SecureConf
  class Config < Hash
    attr_reader :path
    attr_reader :encripter
    attr_reader :serializer
    attr_reader :storage
    attr_accessor :auto_commit

    def initialize(path, encripter: nil, serializer: nil, storage: nil, auto_commit: true)
      @path = path
      @encripter = encripter || SecureConf.default
      @serializer = serializer || Serializer::Marshal
      @storage = storage || Storage.fetch(path)
      @auto_commit = auto_commit
      self.replace(@storage.load(path))
    end

    alias_method :plain_store, :store

    def store(key, value)
      if key.to_s.start_with?("enc:")
        secure_store(key, value)
      else
        plain_store(key, value)
      end
    end
    alias_method :[]=, :store

    def secure_store(key, value)
      value = @serializer.dump(value)
      plain_store(key, @encripter.encrypt(value))
    end

    alias_method :plain_get, :[]

    def [](key)
      value = plain_get(key)
      if value && key.to_s.start_with?("enc:")
        value = @encripter.decrypt(value)
        value = @serializer.load(value)
      end
      value
    end

    def save
      @storage.save(path, self)
    end
  end
end
