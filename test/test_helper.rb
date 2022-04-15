$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "secure_conf"

OPENSSH_PRIVATEKEY = "-----BEGIN OPENSSH PRIVATE KEY-----
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
-----END OPENSSH PRIVATE KEY-----"

PEM_PRIVATEKEY = "-----BEGIN RSA PRIVATE KEY-----
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
-----END RSA PRIVATE KEY-----"

require "minitest/autorun"
