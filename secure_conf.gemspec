# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'secure_conf/version'

Gem::Specification.new do |spec|
  spec.name          = "secure_conf"
  spec.version       = SecureConf::VERSION
  spec.authors       = ["yoshida"]
  spec.email         = ["yoshida.eth0@gmail.com"]

  spec.summary       = %q{To encrypt the configuration value.}
  spec.description   = %q{To encrypt the configuration value.}
  spec.homepage      = "https://github.com/yoshida-eth0/ruby-secure_conf"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
