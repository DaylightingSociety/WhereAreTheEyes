#!/usr/bin/env ruby

require_relative "../map"

if( ARGV.size != 2 )
	puts "USAGE: #{$0} <latitude> <longitude>"
	exit
end

(lat, lon) = ARGV
pins = Map.getPins(lat, lon, 1000000)
puts "Pins near #{lat} #{lon}:"
for pin in pins do
	puts "\t#{pin[0]} #{pin[1]} Verifies: #{pin[2]}"
end

