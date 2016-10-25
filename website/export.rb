#!/usr/bin/env ruby

require_relative 'configuration'
require_relative 'map'

=begin
	This module is responsible for exporting our data for public consumption.
	Right now we only export as CSV, but maybe some day we can also provide
	more useful formats.
=end

module Export
	# Takes file to save to, returns full path to exported file
	def self.exportPinsCSV(filename)
		data = Map.getAllPins()
		path = Configuration::ExportDir + "/#{filename}"
		f = File.open(path, "w")
		f.write("latitude,longitude\n")
		for cam in data
			f.write("#{cam[0]},#{cam[1]}\n")
		end
		f.close()
		return path
	end
end
