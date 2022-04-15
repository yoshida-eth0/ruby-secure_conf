require "test_helper"
require 'stringio'

class OpenSSHTest < Minitest::Test
  def test_initialize
    # string
    ssh_pkey = SecureConf::OpenSSH::PKey.new(OPENSSH_PRIVATEKEY)
    assert_kind_of SecureConf::OpenSSH::PKey, ssh_pkey

    # io
    io = StringIO.new(OPENSSH_PRIVATEKEY)
    ssh_pkey = SecureConf::OpenSSH::PKey.new(io)
    assert_kind_of SecureConf::OpenSSH::PKey, ssh_pkey
  end

  def test_to_openssl_pem
    ssh_pkey = SecureConf::OpenSSH::PKey.new(OPENSSH_PRIVATEKEY)
    assert_equal PEM_PRIVATEKEY, ssh_pkey.to_openssl_pem
  end

  def test_to_openssl
    ssh_pkey = SecureConf::OpenSSH::PKey.new(OPENSSH_PRIVATEKEY)
    assert_kind_of OpenSSL::PKey::RSA, ssh_pkey.to_openssl
  end
end
