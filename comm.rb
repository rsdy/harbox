#!/usr/bin/ruby1.8

require 'rubygems'
require 'serialport'
require 'openssl'

ser = SerialPort.new ARGV[0], ARGV[1].to_i, 8, 1, SerialPort::NONE

msg = ARGV[2]
ser.puts "#{msg}#{OpenSSL::HMAC.digest('sha1', 'asdf', msg)}"
ser.flush

sleep 1
if buf = ser.read
  print buf
  $stdout.flush
end
ser.close
