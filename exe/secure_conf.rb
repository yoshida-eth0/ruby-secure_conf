#!/bin/ruby

$LOAD_PATH << File.expand_path("../lib", File.dirname(__FILE__))

require 'secure_conf'

method = (ARGV[0]||"").to_sym
path = ARGV[1]
key = ARGV[2]
value = ARGV[3]

class SecureConfCmd

  def initialize(path)
    @path = path
  end

  def config
    unless @config
      unless @path
        raise "path is required."
      end
      #unless File.file?(@path)
      #  raise "path is not found."
      #end

      @config = SecureConf::Config.new(@path, auto_commit: true)
    end
    @config
  end

  def read(key)
    raise "key is required." unless key

    val = config[key]

    puts "read"
    puts "  key: #{key}"
    puts "  val: #{val}"
  end

  def write(key, value)
    raise "key is required." unless key
    raise "value is required." unless value

    puts "write"
    puts "  key: #{key}"
    puts "  val: #{value}"
    config[key] = value
    puts "write ok."
  end

  def delete(key)
    raise "key is required." unless key

    puts "delete"
    puts "  key: #{key}"
    config.delete(key)
    puts "delete ok."
  end

  def usage
    lines = []
    lines << "Usage:"
    lines << "  #{File.basename($0)} method path [key [value]]"
    lines << ""
    lines << "  method:"
    lines << "    read write delete"
    lines << ""
    lines << "  required args"
    lines << "    read  : path key"
    lines << "    write : path key value"
    lines << "    delete: path key"
    lines.join("\n")
  end
end


cmd = SecureConfCmd.new(path)

begin
  case method
  when :read
    cmd.read(key)
  when :write
    cmd.write(key, value)
  when :delete
    cmd.delete(key)
  else
    puts cmd.usage
  end
rescue => e
  puts e
  puts
  puts cmd.usage

  #puts e.backtrace.join("\n")
end
