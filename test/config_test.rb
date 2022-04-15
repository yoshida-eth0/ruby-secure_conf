require "test_helper"
require 'tmpdir'

class ConfigTest < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir("secure_config_minitest")
    @storage_path = "#{@tmpdir}/config.yml"
    @config = SecureConf::Config.new(@storage_path, encrypter: SecureConf::Encrypter.new(PEM_PRIVATEKEY))

    @pkey = OpenSSL::PKey::RSA.new(PEM_PRIVATEKEY)
  end

  def teardown
    FileUtils.remove_entry_secure(@tmpdir)
  end

  def test_plain
    # store
    @config["email"] = "user1@example.com"

    # get
    assert_equal "user1@example.com", @config["email"]
    assert_equal "user1@example.com", @config.plain_get("email")

    # delete
    @config.delete("email")
    assert_nil @config["email"]
  end

  def test_secure
    # store
    @config["enc:password"] = "secret1234567890"

    # get
    assert_equal "secret1234567890", @config["enc:password"]

    # decription
    b64 = @config.plain_get("enc:password")
    enc = Base64::strict_decode64(b64)
    marshal = @pkey.private_decrypt(enc)
    dec = Marshal.load(marshal)
    assert_equal "secret1234567890", dec

    # delete
    @config.delete("enc:password")
    assert_nil @config["enc:password"]
  end

  def test_save
    @config["key1"] = "value1"
    @config["enc:key2"] = "key2"
    @config.save

    # exists
    assert File.exist?(@storage_path)

    # equals
    assert_match(/^---\nkey1: value1\nenc:key2: [a-zA-Z0-9\+\/=]+\n$/, File.open(@storage_path, "r") {|f| f.read })
  end
end
