#!/usr/bin/env ruby

require 'kramdown'
require_relative 'configuration'

=begin
	This file contains utility functions several different files may
	want access to, like markdown rendering.
=end

# To sort posts numerically we need to get their number
# This is everything up to the "_", converted to an int
def getPostNumber(filename)
	return filename[/^(.+?)_/].to_i
end

def getMarkdown(filename)
	begin
		t = File.read(Configuration::Private + "/" + filename)
		return Kramdown::Document.new(t).to_html
	rescue Exception => e
		return ""
	end
end
