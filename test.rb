#!/usr/bin/ruby1.8

require 'rubygems'
require 'serialport'
require 'openssl'
require 'socket'

@ip = '192.168.10.210'
@port = 23
@device = '/dev/ttyUSB0'
@baud = 9600
@read_delay = 0.1

def stream
  return TCPSocket.open @ip, @port if ARGV[0] == '--net'
  @serialport ||= SerialPort.new @device, @baud, 8, 1, SerialPort::NONE
end

def hash *args; OpenSSL::HMAC.digest(*(args.unshift('sha1'))); end

def put_data cmd, msg, key
  packet = [cmd[0].ord, msg.length + 20, msg].pack("CCA*")
  stream.puts "#{packet}#{hash key, packet}"
  stream.flush
end

def run_test name, cmd, msg, expected, key
  expected_hash = hash key, expected

  put_data cmd, msg, key
  sleep @read_delay

  answer = stream.readpartial(128) rescue ''
  puts case
    when answer[0...-20] != expected
      "FAIL - #{name} - received: #{answer} (len: #{answer.length})"
    when expected.length > 0 && answer[-20..-1] != expected_hash
      "FAIL - #{name} - hash mismatch"
    else
      "OK - #{name}"
    end
end

def run_testset count, testset
  1.upto(count) { |run|
    testset.each { |args| run_test(*args) }
    puts "---------- run : #{run} ----------"
  }
end

### test cases
run_testset 2, [
   ['echo',          'e', 'testwhat1',   'testwhat1',  'asdf'],
   ['echo',          'e', 'testwhat1',   'testwhat1',  'asdf'],
   ['wrong-echo',    'e', 'whatevz',     '',           'asdf213'],
   ['echo',          'e', 'test_msg_2',  'test_msg_2', 'asdf'],
   ['wrong-command', ';', 'whatevz',     '',           'asdf'],
   #['configuration', 'c', [127, 0, 0, 1,
                           #255, 255, 255, 0,
                           #0x00, 0x11, 0x22, 0x33, 0x44, 0x55,
                           #192, 168, 1, 50,
                           #0x00,
                           #192, 168, 1, 102,
                           #10000 & 0x00ff, (10000 & 0xff00) >> 8, # little endian
                           #4,
                           #0x61, 0x73, 0x64, 0x66].pack('C*'), 'OK', 'HMAC-key'],

    #['reboot', 'b', '', '', 'asdf']
  ]

@serialport.close if @serialport
