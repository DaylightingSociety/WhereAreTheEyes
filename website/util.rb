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
		f = File.open(Configuration::Private + "/" + filename, "r:UTF-8")
		t = f.read
		f.close
		return Kramdown::Document.new(t).to_html
	rescue Exception => e
		return ""
	end
end

# Should always be passed 'request' from an HTTP context
# Returns a list of accepted languages, in order of preference
def getLanguageList(request)
	rx = /([A-Za-z]{2}(?:-[A-Za-z]{2})?)(?:;q=(1|0?\.[0-9]{1,3}))?/
	langs = request.env['HTTP_ACCEPT_LANGUAGE'].to_s.scan(rx).map do |lang, q|
		[lang, (q || '1').to_f]
	end
	return langs.sort_by(&:last).map(&:first).reverse
end

# Returns the best-option language given a list
# of languages the user's browser accepts
def getPreferredLanguage(languageList)
	for i in languageList
		if Configuration::AcceptedLanguages.include?(i)
			return i
		end
	end
	return Configuration::DefaultLanguage
end
