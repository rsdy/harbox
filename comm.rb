#!/usr/bin/ruby1.8

require 'rubygems'
#require 'serialport'
require 'openssl'

require 'socket'

#@ser = SerialPort.new ARGV[0], ARGV[1].to_i, 8, 1, SerialPort::NONE

def put_data cmd, msg, key, hash
  @ser.putc cmd
  @ser.putc msg.length + 20
  @ser.puts "#{msg}#{hash}"
  @ser.flush
end

def run_test name, cmd, msg, expected, key
  @ser = TCPSocket.open '192.168.1.254', 23
  output_hash = OpenSSL::HMAC.digest('sha1', key, msg)
  expected_hash = OpenSSL::HMAC.digest('sha1', key, expected)

  put_data cmd, msg, key, output_hash
  sleep 0.1
  answer = @ser.readpartial(128) rescue ''
  puts case
    when answer[0...-20] != expected
      "FAIL - #{name} - received: #{answer} (len: #{answer.length})"
    when expected.length > 0 && answer[-20..-1] != expected_hash
      "FAIL - #{name} - hash mismatch"
    else
      "OK - #{name}"
    end
end

1.upto(1) { |x|
  [
   ['echo',          'e', 'test_msg_1',  'test_msg_1', 'asdf'],
   ['wrong-echo',    'e', 'whatevz',     '',           'asdf213'],
   ['echo',          'e', 'test_msg_2',  'test_msg_2', 'HMAC-key'],
   ['wrong-command', ';', 'whatevz',     '',           'asdf'],
   ['configuration', 'c', [127, 0, 0, 1,
                           255, 255, 255, 0,
                           0x00, 0x11, 0x22, 0x33, 0x44, 0x55,
                           192, 168, 1, 50,
                           0x00,
                           192, 168, 1, 102,
                           10000 & 0xff00, 10000 & 0x00ff,
                           4,
                           0x61, 0x73, 0x64, 0x66].pack('C*'), 'OK', 'HMAC-key'],

    ['reboot', 'b', '', '', 'asdf']
  ].each { |args| run_test *args }

  puts '---------------------'
}

@ser.close
