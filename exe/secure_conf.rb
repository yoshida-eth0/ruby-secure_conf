#!/bin/ruby

$LOAD_PATH << File.expand_path("../lib", File.dirname(__FILE__))

require 'secure_conf'
require 'optparse'

class SecureConfCmd

  def initialize(storage_path, privatekey_path=nil)
    @storage_path = File.expand_path(storage_path)
    @privatekey_path = File.expand_path(privatekey_path)
  end

  def config
    unless @config
      #unless File.file?(@storage_path)
      #  raise "storage_path is not exist: #{@storage_path}"
      #end

      unless File.file?(@privatekey_path)
        raise "privatekey_path is not exist: #{@privatekey_path}"
      end

      pkey = File.open(@privatekey_path, "r") {|f| f.read}

      @config = SecureConf::Config.new(@storage_path, encrypter: SecureConf::Encrypter.new(pkey), auto_commit: true)
    end
    @config
  end

  def read(key)
    val = config[key]

    puts "read"
    puts "  key: #{key}"
    puts "  val: #{val}"
  end

  def write(key, value)
    puts "write"
    puts "  key: #{key}"
    puts "  val: #{value}"
    config[key] = value
    puts "write ok."
  end

  def delete(key)
    puts "delete"
    puts "  key: #{key}"
    config.delete(key)
    puts "delete ok."
  end
end


# default value
privatekey_path = "~/.ssh/id_rsa"
storage_path = "./secure.yml"
method = nil
key = nil
value = nil

# parser
parser = OptionParser.new {|o|
  o.banner = "Usage: #{File.basename($0)} [options] method [arguments]..."
  o.on('--pkey privatekey_path', "PrivateKey file path (default: #{privatekey_path})") {|v| privatekey_path = v }
  o.on('--storage storage_path', "Storage file path (default: #{storage_path})") {|v| storage_path = v }
  o.on_tail(
    "  methods usage:",
    "    #{File.basename($0)} [options] read key",
    "    #{File.basename($0)} [options] write key value",
    "    #{File.basename($0)} [options] delete key",
  )
  o.version = SecureConf::VERSION
}

methods = {
  read: 1,
  write: 2,
  delete: 1,
}

# parse argv
begin
  parser.parse!(ARGV)

  # method
  method = ARGV.shift
  unless method
    raise ""
  end
  method = method.to_sym
  unless methods.include?(method)
    raise "not found method: #{method}"
  end

  # method argc
  unless ARGV.length==methods[method]
    raise "wrong number of method arguments: method=#{method} given=#{ARGV.length} expected=#{methods[method]}"
  end

  # key value
  key = ARGV[0]
  value = ARGV[1]

rescue => e
  if 0<e.message.to_s.length
    puts e.message
    puts
  end
  puts parser.help
  exit(1)
end


# execute
cmd = SecureConfCmd.new(storage_path, privatekey_path)

begin
  case method
  when :read
    cmd.read(key)
  when :write
    cmd.write(key, value)
  when :delete
    cmd.delete(key)
  end
rescue => e
  puts e
  puts
  puts parser.help

  #puts e.backtrace.join("\n")
end
