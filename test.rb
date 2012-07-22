#!/usr/bin/ruby1.8
#
# Copyright (C) 2012 Peter Parkanyi <me@rhapsodhy.hu>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is furnished to do
# so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
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
  return TCPSocket.open @ip, @port if ARGV.include? '--net'
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
## name              cmd  msg            answer        hmac key
   ['echo',          'e', 'testwhat1',   'testwhat1',  'asdf'],
   ['echo',          'e', 'testwhat1',   'testwhat1',  'asdf'],
   ['wrong-echo',    'e', 'whatevz',     '',           'asdf213'],
   ['echo',          'e', 'test_msg_2',  'test_msg_2', 'asdf'],
   ['wrong-command', ';', 'whatevz',     '',           'asdf'],
   ['echo',          'e', 'test_msg_3',  'test_msg_3', 'asdf'],
]

if false
run_testset 1, [
   ['configuration', 'c', [127, 0, 0, 1,
                           255, 255, 255, 0,
                           0x00, 0x11, 0x22, 0x33, 0x44, 0x55,
                           192, 168, 1, 50,
                           0x00,
                           192, 168, 1, 102,
                           10000 & 0x00ff, (10000 & 0xff00) >> 8, # little endian
                           4,
                           0x61, 0x73, 0x64, 0x66].pack('C*'), 'OK', 'HMAC-key'],

    ['reboot', 'b', '', '', 'asdf']
]
end

@serialport.close if @serialport
