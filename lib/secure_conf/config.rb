require 'delegate'

module SecureConf
  class Config < SimpleDelegator
    attr_reader :path
    attr_reader :encrypter
    attr_reader :serializer
    attr_reader :storage
    attr_accessor :auto_commit

    def initialize(path, encrypter: nil, serializer: nil, storage: nil, auto_commit: false)
      @path = path
      @encrypter = encrypter || SecureConf.default
      @serializer = serializer || Serializer::Marshal
      @storage = storage || Storage.fetch(path)
      @auto_commit = auto_commit
      super(@storage.load(path))
    end

    # store

    def plain_store(key, value)
      __getobj__.store(key, value)
      save if @auto_commit
    end

    def secure_store(key, value)
      value = @serializer.dump(value)
      plain_store(key, @encrypter.encrypt(value))
    end

    def store(key, value)
      if key.to_s.start_with?("enc:")
        secure_store(key, value)
      else
        plain_store(key, value)
      end
    end
    alias_method :[]=, :store

    # get

    def plain_get(key)
      __getobj__[key]
    end

    def [](key)
      value = plain_get(key)
      if value && key.to_s.start_with?("enc:")
        value = @encrypter.decrypt(value)
        value = @serializer.load(value)
      end
      value
    end

    # delete

    def delete(key)
      __getobj__.delete(key)
      save if @auto_commit
    end

    # save

    def save
      @storage.save(path, __getobj__)
    end
  end
end
