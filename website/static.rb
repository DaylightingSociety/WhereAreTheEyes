#!/usr/bin/env ruby

=begin
	This file handles all of our static webpages, like the about page and the
	blog. It does *not* handle the RESTful API for device interaction with
	the map.
=end

require_relative 'configuration'
require_relative 'util'

get '/' do
	text = ""
	posts = Dir.entries(Configuration::PostsDir).select do |f| 
		File.file?(Configuration::PostsDir + "/" + f) and f.end_with?(".md")
	end
	posts.sort! { |x, y| getPostNumber(x) <=> getPostNumber(y) }
	posts.reverse! # Put newest posts first
	# Display only three or so posts on the front page
	if( posts.size > Configuration::FrontPagePostHistory )
		posts = posts.take(Configuration::FrontPagePostHistory)
	end
	for post in posts
		text += (getMarkdown("posts/" + post) + Configuration::PostSeparator)
	end
	erb :status, :locals => { :text => text }
end

get '/allPosts' do
	text = ""
	posts = Dir.entries(Configuration::PostsDir).select do |f| 
		File.file?(Configuration::PostsDir + "/" + f) and f.end_with?(".md")
	end
	posts.sort! { |x, y| getPostNumber(x) <=> getPostNumber(y) }
	for post in posts.reverse
		text += (getMarkdown("posts/" + post) + Configuration::PostSeparator)
	end
	erb :markdown, :locals => { :text => text }
end

get '/secretPreviews/:password' do |password|
	pause = rand(0.0 .. 1.0)
	sleep(pause) # Protect us from password guessing attacks
	if( password == Configuration::MasterPinReadingPassword )
		text = ""
		posts = Dir.entries(Configuration::PreviewDir).select do |f|
			File.file?(Configuration::PreviewDir + "/" + f) and f.end_with?(".md")
		end
		posts.sort! { |x, y| getPostNumber(x) <=> getPostNumber(y) }
		for post in posts.reverse
			text += (getMarkdown("preview/" + post) + "\n<hr>\n")
		end
		erb :markdown, :locals => { :text => text }
	else
		return "ACCESS DENIED"
	end
end

get '/archive' do
	filenames = Dir.entries(Configuration::PostsDir).select do |f|
		File.file?(Configuration::PostsDir + "/" + f) and f.end_with?(".md")
	end
	filenames.sort! { |x, y| getPostNumber(x) <=> getPostNumber(y) }
	filenames.reverse! # Put newest posts on top
	posts = []
	for file in filenames
		posts.push(File.basename(file, ".md"))
	end
	erb :archive, :locals => { :posts => posts }
end

get '/post/:name' do |name|
	if( name =~ /[^A-Za-z0-9_]/ )
		halt 404
	end
	if( File.exists?(Configuration::PostsDir + "/" + name + ".md") )
		fname = Configuration::PostsDirName + "/" + name + ".md"
		erb :markdown, :locals => { :text => getMarkdown(fname) }
	else
		redirect '/notfound'
	end
end

get '/rawdata/' do
	redirect to("/rawdata")
end

get '/rawdata' do
	filenames = Dir.entries(Configuration::ExportDir).select do |f|
		File.file?(Configuration::ExportDir + "/" + f) and f.end_with?(".csv")
	end
	filenames.sort!
	filenames.reverse! # Put newest data on top
	dirname = File.basename(Configuration::ExportDir)
	erb :rawdata, :locals => { :datadir => dirname, :files => filenames }
end

get '/rawdata/newest' do
	filenames = Dir.entries(Configuration::ExportDir).select do |f|
		File.file?(Configuration::ExportDir + "/" + f) and f.end_with?(".csv")
	end
	filenames.sort!
	if( filenames.size > 0 )
		redirect "/rawdata/#{filenames.pop}"
	else
		halt 404
	end
end

get '/downloads' do
	erb :downloads
end

get '/downloads/ios' do
	redirect "https://itunes.apple.com/us/app/where-are-the-eyes/id1152202149?mt=8"
end

get '/downloads/android' do
	redirect "https://play.google.com/store/apps/details?id=org.daylightingsociety.wherearetheeyes&utm_source=global_co&utm_medium=prtnr&utm_content=Mar2515&utm_campaign=PartBadge&pcampaignid=MKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1"
end

get '/downloads/f-droid' do
	redirect "https://f-droid.org/app/org.daylightingsociety.wherearetheeyes"
end

get '/about' do
	md = getMarkdown("about.md")
	erb :about, :locals => { :text => md }
end

get '/propaganda' do
	erb :propaganda
end
