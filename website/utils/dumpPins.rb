#!/usr/bin/env ruby

require_relative '../map'

pins = Map.getAllPins
for pin in pins
	printf("%f\t%f\n", pin[0], pin[1])
end
