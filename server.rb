#!/usr/bin/ruby

require 'socket'

server = TCPServer.open(80)

loop do
	socket = server.accept
	
	puts '== connect'
	begin
		socket.each_line do |line|
			puts "[#{Time.now}]: #{line}"
		end
	rescue
		puts '= clientdisc'
	ensure
		socket.close
	end
		puts '== disconnect'
end
