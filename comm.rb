#!/usr/bin/ruby1.8

require 'rubygems'
require 'serialport'
require 'openssl'

@ser = SerialPort.new ARGV[0], ARGV[1].to_i, 8, 1, SerialPort::NONE

def put_data cmd, msg, key, hash
  @ser.putc cmd
  @ser.putc msg.length + 20
  @ser.puts "#{msg}#{hash}"
  @ser.flush
end

def run_test name, cmd, msg, expected, key
  output_hash = OpenSSL::HMAC.digest('sha1', key, msg)
  expected_hash = OpenSSL::HMAC.digest('sha1', key, expected)

  put_data cmd, msg, key, output_hash
  sleep 0.1
  answer = @ser.read
  puts case
    when answer[0...-20] != expected
      "FAIL - #{name} - received: #{answer} (len: #{answer.length})"
    when expected.length > 0 && answer[-20..-1] != expected_hash
      "FAIL - #{name} - hash mismatch"
    else
      "OK - #{name}"
    end
end

1.upto(3) { |x|
  [['echo',       'e', 'test_msg_1', 'test_msg_1', 'asdf'],
   ['wrong-echo', 'e', 'whatevz', '', 'asdf213'],
   ['echo',       'e', 'test_msg_2', 'test_msg_2', 'asdf'],
   ['wrong-command', ';', 'whatevz', '', 'asdf213']
  ].each { |args| run_test *args }

  puts '---------------------'
}

@ser.close
