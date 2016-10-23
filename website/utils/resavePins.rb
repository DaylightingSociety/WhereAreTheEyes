#!/usr/bin/env ruby
require_relative '../configuration'
require_relative '../map'

=begin
	This utility loads and re-saves pins to disk. This is so that if 
	we change our database format we can cleanly migrate pins and not
	lose any data.

	NOTE: To use this you'll need to temporarily remove the
	'private_class_method' from loadPins and savePin.

	WARNING: Make sure this script is running as the web-user, or fix
	permissions afterwards to make sure the pin databases are still writable!
=end

files = Dir.entries(Configuration::PinDir).select{ |f| f.end_with?(".db") }
i = 0
for file in files
	pins = Map.loadPins(file)
	for p in pins
		Map.savePin(p)
		i += 1
	end
	puts "Done with #{file}"
	File.unlink(Configuration::PinDir + "/" + file)
end
puts "Re-saved #{i} pins"
