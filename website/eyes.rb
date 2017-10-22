#!/usr/local/bin/ruby
# encoding: UTF-8
require 'sinatra'
require 'tilt/erb'

if( Sinatra::Base.production? )
	require 'encrypted_cookie'
end

require_relative 'static'
require_relative 'rss'
require_relative 'state'
require_relative 'auth'
require_relative 'api'
require_relative 'log'
require_relative 'configuration'


error Sinatra::NotFound do
	erb :notfound
end

# Force any 404 errors to display the 404 page
not_found do 
	status 404
	erb :notfound
end

# This block forces SSL for all users all the time.
# Always on in deployment, but unnecessary when debugging locally
if( Sinatra::Base.production? )
	before '*' do
		if( request.url.start_with?("http://") )
			redirect to(request.url.sub("http", "https"))
		end
	end
end

Log.init
State.init
State.startWatchdog

# Set up encrypted session cookies for use during registration
if( Sinatra::Base.production? )
	use Rack::Session::EncryptedCookie, :secret => State.getSecret(), :expire_after => Configuration::CookieDuration
end
