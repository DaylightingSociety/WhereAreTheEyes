#!/usr/local/bin/ruby
# encoding: UTF-8
require 'sinatra'
require 'encrypted_cookie'
require 'tilt/erb'

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

# This block forces SSL for all users all the time.
before '*' do
	if( request.url.start_with?("http://") )
		redirect to(request.url.sub("http", "https"))
	end
end

Log.init
State.init
State.startWatchdog

# Set up encrypted session cookies for use during registration
use Rack::Session::EncryptedCookie, :secret => State.getSecret(), :expire_after => Configuration::CookieDuration
