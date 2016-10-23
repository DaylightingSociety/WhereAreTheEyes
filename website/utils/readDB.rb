#!/usr/bin/env ruby

require_relative "../map"

for db in ARGV do
	puts "Pins in #{db}:"
	pins = Map.loadPins(db)
	for p in pins do
		puts "\t#{p.latitude} #{p.longitude} #{p.verifies}"
	end
end
