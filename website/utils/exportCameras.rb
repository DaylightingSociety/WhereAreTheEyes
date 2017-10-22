#!/usr/bin/env ruby
require_relative '../export'
require_relative '../configuration'

=begin
This script manually exports cameras to a CSV and rebuilds
the pretty picture on the front of the website.
=end

target = Time.now.strftime("%Y-%m-%d.csv")
path = Export.exportPinsCSV(target)
if( Configuration::ExportImageEnabled )
	system("#{Configuration::ExportImageScript} #{path} #{Configuration::ExportImagePath}")
end
