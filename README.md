# SecureConf

To encrypt the configuration value.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'secure_conf'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install secure_conf

## Usage

    path = File.expand_path("secure.yml", File.dirname(__FILE__))
    config = SecureConf::Config.new(path)
    
    config["enc:id"] = "yoshida-eth0"
    config["enc:pass"] = "himitsu"
    config["last_access"] = Time.now.to_s
    config.save
    
    p config["enc:id"]
    p config["enc:pass"]
    p config["last_access"]

## Usage cli

    % secure_conf.rb read enc:pass
    read
      key: enc:pass
      val: himitsu

    % secure_conf.rb --help
    Usage: secure_conf.rb [options] method [arguments]...
            --pkey privatekey_path       PrivateKey file path (default: ~/.ssh/id_rsa)
            --storage storage_path       Storage file path (default: ./secure.yml)
      methods usage:
        secure_conf.rb [options] read key
        secure_conf.rb [options] write key value
        secure_conf.rb [options] delete key

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yoshida-eth0/ruby-secure_conf.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

