#!/usr/bin/env ruby

require_relative 'configuration'
require_relative 'auth'
require_relative 'map'
require_relative 'scores'
require_relative 'location'
require_relative 'ratelimit'

=begin
	This file is responsible for the RESTful API interactions with clients.
	That means it handles all the HTTP-like stuff, and then calls out to the
	appropriate parts of the codebase to get the job done.
=end

# Returns a CSV list of "latitude, longitude, number of verifies" for all pins
# near a specified GPS coordinate.
# For now we don't actually use 'zoom' here, but later it can let us take
# shortcuts and not have to care about pins outside view range
get '/getPins/:latitude/:longitude/:zoom' do |latitude, longitude, zoom|
	# The last arg will later be a radius based on zoom level
	#pins = Map.getPins(latitude, longitude, 999999)
	pins = Map.getAllPins
	csv = ""
	for pin in pins
		csv += "#{pin[0]}, #{pin[1]}, #{pin[2]}\n"
	end
	return csv
end

# Same as /getPins, except that we return *all* pins.
# This is not confidential information, but we do not want most users to be
# able to put a heavy load on our servers. This is part of the API so that
# admins can easily gather statistics or debug the pin code.
# Access is restricted by a master password to this end.
get '/getAllPins/:password' do |password|
	pause = rand(0.0 .. 1.0)
	sleep(pause) # Protect us from password guessing attacks
	if( password == Configuration::MasterPinReadingPassword )
		pins = Map.getAllPins
		csv = ""
		for pin in pins
			csv += "#{pin[0]}, #{pin[1]}, #{pin[2]}\n"
		end
		return csv
	end
	return "ACCESS DENIED"
end

# Returns "cameras_marked, verifications_made" for a user
get '/getScore/:username' do |username|
	scores = Scores.getUserScore(username)
	if( scores == nil )
		return "ERROR: Invalid login\n"
	else
		return "#{scores.cameras}, #{scores.verifications}\n"
	end
end

# Gathers username and coordinates, marks or verifies the pin *if* the user
# exists.
post '/markPin' do
	username = params['username']
	longitude = params['longitude'].to_f
	latitude = params['latitude'].to_f
	unless( Location.ipInRange?(request.ip, latitude, longitude) )
		return "ERROR: Geoip out of range\n"
	end
	if( Auth.validLogin?(username) )
		if( RateLimit.rateExceeded?(request.ip) )
			return "ERROR: Rate limit exceeded\n"
		else
			Map.addPin(latitude, longitude, username)
			RateLimit.addRecord(request.ip)
			return "SUCCESS: Pin posted or verified\n"
		end
	else
		return "ERROR: Invalid login\n"
	end
end

# Gathers username and coordinates, attempts to remove verifications by
# that user for the specified pin.
post '/unmarkPin' do
	username = params['username']
	longitude = params['longitude'].to_f
	latitude = params['latitude'].to_f
	unless( Location.ipInRange?(request.ip, latitude, longitude) )
		return "ERROR: Geoip out of range\n"
	end
	if( Auth.validLogin?(username) )
		if( RateLimit.rateExceeded?(request.ip) )
			return "ERROR: Rate limit exceeded\n"
		else
			RateLimit.addRecord(request.ip)
			if( Map.unverifyPin(latitude, longitude, username) )
				return "SUCCESS: Pin verification revoked\n"
			else
				return "ERROR: Permission denied\n"
			end
		end
	else
		return "ERROR: Permission denied\n"
	end
end
