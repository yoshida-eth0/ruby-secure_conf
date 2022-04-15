require "test_helper"

class SerializerTest < Minitest::Test
  def setup
  end

  def teardown
  end

  def test_marshal
    # string
    original = "hello world"
    serial = SecureConf::Serializer::Marshal.dump(original)
    restore = SecureConf::Serializer::Marshal.load(serial)
    assert_equal original, restore

    # symbol
    original = :symbol123
    serial = SecureConf::Serializer::Marshal.dump(original)
    restore = SecureConf::Serializer::Marshal.load(serial)
    assert_equal original, restore

    # integer
    original = 1234567890
    serial = SecureConf::Serializer::Marshal.dump(original)
    restore = SecureConf::Serializer::Marshal.load(serial)
    assert_equal original, restore

    # hash
    original = {string: "hello", symbol: :world, integer: 1234567890}
    serial = SecureConf::Serializer::Marshal.dump(original)
    restore = SecureConf::Serializer::Marshal.load(serial)
    assert_equal original, restore

    # array
    original = ["hello world", :symbol123, 1234567890, {key1: "hello", key2: :world}]
    serial = SecureConf::Serializer::Marshal.dump(original)
    restore = SecureConf::Serializer::Marshal.load(serial)
    assert_equal original, restore
  end

  def test_json
    # string
    original = "hello world"
    serial = SecureConf::Serializer::JSON.dump(original)
    restore = SecureConf::Serializer::JSON.load(serial)
    assert_equal original, restore

    # symbol
    original = :symbol123
    serial = SecureConf::Serializer::JSON.dump(original)
    restore = SecureConf::Serializer::JSON.load(serial)
    assert_equal original.to_s, restore

    # integer
    original = 1234567890
    serial = SecureConf::Serializer::JSON.dump(original)
    restore = SecureConf::Serializer::JSON.load(serial)
    assert_equal original, restore

    # hash
    original = {string: "hello", symbol: :world, integer: 1234567890}
    serial = SecureConf::Serializer::JSON.dump(original)
    restore = SecureConf::Serializer::JSON.load(serial)
    assert_equal({"string" => "hello", "symbol" => "world", "integer" => 1234567890}, restore)

    # array
    original = ["hello world", :symbol123, 1234567890, {key1: "hello", key2: :world}]
    serial = SecureConf::Serializer::JSON.dump(original)
    restore = SecureConf::Serializer::JSON.load(serial)
    assert_equal ["hello world", "symbol123", 1234567890, {"key1" => "hello", "key2" => "world"}], restore
  end
end
