require "test_helper"
require 'tmpdir'

class StorageTest < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir("secure_config_minitest")
  end

  def teardown
    FileUtils.remove_entry_secure(@tmpdir)
  end

  def test_yaml
    storage_path = "#{@tmpdir}/storage.yml"

    original = {key1: "hello", key2: "world"}
    SecureConf::Storage::Yaml.save(storage_path, original)
    restore = SecureConf::Storage::Yaml.load(storage_path)
    assert_equal original, restore
  end
end
