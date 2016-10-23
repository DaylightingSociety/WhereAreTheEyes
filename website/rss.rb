#!/usr/bin/env ruby

=begin
	This file is responsible for our RSS feed, and nothing else.
=end

require_relative 'configuration'

get '/rss' do
	xml = <<END_XML
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0">
<channel>
<title>#{Configuration::Title}</title>
<link>https://#{Configuration::SiteUrl}/</link>
<description>#{Configuration::Description}</description>
END_XML
	posts = Dir.entries(Configuration::PostsDir).select do |f|
		File.file?(Configuration::PostsDir + "/" + f) and f.end_with?(".md")
	end
	posts = posts.sort.reverse # Put newest posts on top
	for i in (0 .. 10)
		if( i >= posts.size )
			break
		end
		begin
			name = File.basename(posts[i], ".md")
			contents = getMarkdown("posts/" + posts[i])
			xml += "<item>\n"
			xml += "<title>#{name}</title>\n"
			xml += "<link>post/#{name}</link>\n"
			xml += "<description><![CDATA[#{contents}]]></description>\n"
			xml += "</item>\n"
		rescue
			next
		end
	end
	xml += "</channel>\n"
	xml += "</rss>"
end


