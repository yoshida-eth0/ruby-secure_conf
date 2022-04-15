require "test_helper"

class EncrypterTest < Minitest::Test
  def setup
  end

  def teardown
  end

  def test_pem
    encrypter = SecureConf::Encrypter.new(PEM_PRIVATEKEY)
    plain_text = "hello world"
    assert_equal plain_text, encrypter.decrypt(encrypter.encrypt(plain_text))
  end

  def test_openssh
    encrypter = SecureConf::Encrypter.new(OPENSSH_PRIVATEKEY)
    plain_text = "hello world"
    assert_equal plain_text, encrypter.decrypt(encrypter.encrypt(plain_text))
  end
end
