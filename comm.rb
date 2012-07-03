#!/usr/bin/ruby1.8

require 'rubygems'
require 'serialport'
require 'openssl'

@ser = SerialPort.new ARGV[0], ARGV[1].to_i, 8, 1, SerialPort::NONE

def put_data cmd, msg, key
  @ser.putc cmd
  @ser.putc msg.length + 20
  @ser.puts "#{msg}#{OpenSSL::HMAC.digest('sha1', key, msg)}"
  @ser.flush
end

def run_test name, cmd, msg, expected, key
  put_data cmd, msg, key
  sleep 0.1
  answer = @ser.read.strip
  if answer != expected
    puts "FAIL - #{name} - received: #{answer}"
    return
  end

  puts "OK - #{name}"
end

1.upto(5) { |x|
  [['echo',       'e', 'test_msg_1', 'test_msg_1', 'asdf'],
   ['wrong-echo', 'e', 'whatevz', '', 'asdf213'],
   ['echo',       'e', 'test_msg_2', 'test_msg_2', 'asdf'],
   ['wrong-command', ';', 'whatevz', '', 'asdf213']
  ].each { |args| run_test *args }

  puts '---------------------'
}

@ser.close
