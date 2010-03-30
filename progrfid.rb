#!/usr/bin/ruby

require 'socket'
include Socket::Constants

puts "== connect =="
socket = TCPSocket.new( "10.10.1.1", 23 )
puts "- send -"
arr = [ 0xaa, 0xbb, 0x11, 0xcc, 0xdd, 0xe1, 10, 10, 2, 1, 10, 10, 2, 5 ]
arr.each { |b| socket.putc b }
puts "- read -"
puts socket.read
puts "== close =="
socket.close
