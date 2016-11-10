#!/usr/bin/env ruby

require 'digest/sha2'
require 'base64'
require 'zlib'
require 'descriptive_statistics'

require_relative 'configuration'
require_relative 'location'
require_relative 'log'
require_relative 'scores'

=begin
	This module stores all pin data for the map, including verifications,
	and can add new pins / verifies, remove older verifications and pins,
	or return information about nearby pins.
=end

class Pin
	attr_reader :latitude, :longitude
	attr_reader :orig_latitude, :orig_longitude

	SecondsInDay = 86400

	def initialize(latitude, longitude, creatorID)
		@latitude = latitude
		@longitude = longitude
		@orig_latitude = latitude
		@orig_longitude = longitude
		@verifies = [[hashUser(creatorID), timeStamp()]]
	end

	# A new user wants to verify this pin! See if they already have.
	# If new verification then add them and return true. If already
	# verified then do nothing and return false.
	def verify(username, latitude, longitude)
		hash = hashUser(username)
		for v in @verifies
			if( v[0] == hash )
				return false
			end
		end
		@verifies.push([hash, timeStamp()])
		# Average the pin positions, so that if several people stand
		# near a camera and verify then we slowly improve our map accuracy
		@latitude = (@latitude + latitude) / 2.0
		@longitude = (@longitude + longitude) / 2.0
		return true
	end

	# Attempts to remove any verifications by a particular user
	# returns true if any verifications removed, false otherwise
	def unverify(username)
		hash = hashUser(username)
		size = @verifies.size
		@verifies.delete_if{ |h| h[0] == hash }
		newSize = @verifies.size
		return !(size == newSize)
	end

	# How many people have verified this pin?
	def verifies
		return @verifies.size
	end

	# Return timestamps from every verification
	def getVerificationTimestamps
		stamps = []
		for v in @verifies
			stamps += [v[1]]
		end
		return stamps
	end

	# Hides usernames so we can check if a user has verified a particular pin
	# We use SHA2 here for performance. It's already an O(n) operation to check
	# if the user has verified this pin, we should at least use a quick hash.
	def hashUser(name)
		if( Configuration::DebugUserEnabled and name == Configuration::DebugUsername )
			return Configuration::DebugUsername
		end
		return (Digest::SHA2.new << (@orig_latitude.to_s + @orig_longitude.to_s + name)).to_s
	end

	# Removes older verifications, so that forgotten pins will slowly fade away
	# Basically we check if the timestamp is older than an arbitrary number
	# of days specified as an argument
	def purgeOldVerifies(days)
		threshold = SecondsInDay * days
		now = timeStamp
		oldCount = @verifies.size
		@verifies.delete_if { |v| (now - v[1]) > threshold }
		newCount = @verifies.size
		if( oldCount > newCount )
			Log.debug("Pin dropped from #{oldCount} to #{newCount} verifies")
		end
	end

	# Removes any verifications by debug accounts.
	# This is useful for situations where we *must* test on production servers,
	# such as getting Apple testers to approve our software.
	def purgeDebugVerifies()
		oldCount = @verifies.size
		@verifies.delete_if { |v| v[0] == Configuration::DebugUsername }
		newCount = @verifies.size
		if( oldCount > newCount )
			Log.debug("Removed #{oldCount - newCount} debug verifications")
		end
	end

	# Returns time of nearest day. This prevents perfect analysis of when a user
	# verified a flag, but still allows us to purge old flags
	def timeStamp
		epoch = Time.now.to_i
		epoch += 43200 # Half a day
		epoch -= (epoch % SecondsInDay) # Round to nearest day
		return epoch	
	end

	private :hashUser
	private :timeStamp
end

module Map
	# Returns the file to look in for points near a particular coordinate
	private_class_method def self.getZoneFile(latitude, longitude)
		rounded_lat = latitude.round(1).to_s
		rounded_lon = longitude.round(1).to_s
		# Note: The regex below is to remove any equals signs from b64 encoding
		return Base64.encode64(rounded_lat + "," + rounded_lon)[/[A-Za-z0-9]+/] + Configuration::PinDBSuffix
	end

	# Returns a list of all the pins in a file
	private_class_method def self.loadPins(filename)
		path = Configuration::PinDir + "/" + filename
		if( File.exists?(path) )
			data = File.read(Configuration::PinDir + "/" + filename)
			return Marshal.load(Zlib::Inflate.inflate(data))
		else
			return []
		end
	end

	# (Re)saves a pin to the database. Adds the pin if it doesn't exist,
	# updates if it already does so we can save new verification data.
	private_class_method def self.savePin(p)
		fname = getZoneFile(p.latitude, p.longitude)
		path = Configuration::PinDir + "/" + fname
		if( File.exists?(path) )
			f = File.open(Configuration::PinDir + "/" + fname, "r+")
			f.flock(File::LOCK_EX)
			pins = Marshal.load(Zlib::Inflate.inflate(f.read))
			addedPin = false
			for i in (0 .. pins.size - 1)
				if( pins[i].latitude == p.latitude && pins[i].longitude == p.longitude )
					addedPin = true
					pins[i] = p
					Log.debug("Updated pin at #{p.latitude} #{p.longitude}")
				end
			end
			if( !addedPin )
				pins.push(p)
				Log.debug("Added pin at #{p.latitude} #{p.longitude}")
			end
			f.rewind
			f.truncate(f.pos)
			f.write(Zlib::Deflate.deflate(Marshal.dump(pins)))
			f.close
		else
			f = File.open(Configuration::PinDir + "/" + fname, "w")
			f.flock(File::LOCK_EX)
			f.write(Zlib::Deflate.deflate(Marshal.dump([p])))
			f.close
		end
	end

	# For now we ignore the radius. Later we can use it as an upper bound and
	# ignore pins that are too far away for the user to care
	# For now we'll just return all the pins anywhere near the user
	def self.getPins(lat, lon, radius)
		# latitude and longitude should be floats, but typecast just in case
		lat = lat.to_f
		lon = lon.to_f
		pins = []
		for i in (0 .. 30)
			for j in (0 .. 30)
				lat_offset = (-1.5 + (0.1 * i)).round(1)
				lon_offset = (-1.5 + (0.1 * j)).round(1)
				fname = getZoneFile(lat + lat_offset, lon + lon_offset)
				ps = loadPins(fname)
				for p in ps
					pins.push([p.latitude, p.longitude, p.verifies])
				end
			end
		end
		return pins
	end

	# If there are no pins close by then add a new one, otherwise
	# verify the existing pin at that location
	def self.addPin(lat, lon, username)
		pins = loadPins(getZoneFile(lat, lon))
		for p in pins
			distance = Location.getDistance(p.latitude, p.longitude, lat, lon)
			if( distance < Configuration::PinOverlapRadius )
				verified = p.verify(username, lat, lon)
				if( verified )
					savePin(p)
					Scores.addVerification(username)
				end
				return false # No new pins, just verified an existing one
			end
		end
		# Hey, we didn't find any similar pins! Great, mark down a new one
		p = Pin.new(lat, lon, username)
		savePin(p)
		Scores.addCamera(username)
		return true # Added a new pin!
	end

	# Searches for pins near the desired location, asks them
	# to unverify the given username. Stops after one success.
	# Returns true if unverification complete, returns false
	# if no appropriate pins found.
	def self.unverifyPin(lat, lon, username)
		f = File.open(Configuration::PinDir + "/" + getZoneFile(lat, lon), "r+")
		Log.debug("Unverifying a pin...")
		f.flock(File::LOCK_EX)
		Log.debug("Unverification lock acquired")
		pins = Marshal.load(Zlib::Inflate.inflate(f.read))
		for p in pins
			distance = Location.getDistance(p.latitude, p.longitude, lat, lon)
			if( distance < Configuration::PinOverlapRadius )
				Log.debug("Attempting unverification...")
				success = p.unverify(username)
				Log.debug("Unverification success: #{success.to_s}")
				if( success ) # Great, need to re-save the pins now
					Log.debug("Resaving pins post unverify...")
					pins.delete_if{ |p| p.verifies == 0 }
					f.seek(0)
					f.truncate(f.pos)
					f.write(Zlib::Deflate.deflate(Marshal.dump(pins)))
					f.close()
					return true # Found an appropriate pin / username combo
				end
			end
		end
		f.close()
		return false # Either couldn't find a pin, or wrong username
	end

	# Triggers a removal of all old pins
	# Should be run periodically to purge outdated data
	def self.deprecatePins()
		zoneFiles = Dir.entries(Configuration::PinDir).select { |f|
			(Configuration::PinDir + "/" + f).end_with?(Configuration::PinDBSuffix)
		}
		for zf in zoneFiles do
			f = File.open(Configuration::PinDir + "/" + zf, "r+")
			f.flock(File::LOCK_EX)
			begin
				pins = Marshal.load(Zlib::Inflate.inflate(f.read))

				# Figure out how many days worth of old data we should purge.
				# We take the median age of verifications, add a 
				# standard deviation, and purge anything older
				Log.debug("Purging zone '#{zf}' with #{pins.size} pins...")
				currentTime = Time.now.to_i
				ages = []
				for p in pins
					for t in p.getVerificationTimestamps
						age = currentTime - t
						ages += [age]
					end
				end
				stdDev = ages.standard_deviation
				median = ages.median
				# We'll get nil if the array was empty (no pins)
				if( pins.size == 0 or stdDev == nil or median == nil )
					next
				end
				# PurgeDays are two standard deviations older than the median
				# age, rounded to the nearest day, plus one.
				#
				# We add one to ensure if all the pins are marked on the same
				# day then they won't be deleted immediately.
				#
				# We set a minimum of 1 to prevent awkward situations like 
				# a single pin, where the std deviation will always be zero,
				# and pin is always purged.
				purgeDays = ((median + (2.0 * stdDev)).round / 86400) + 1
				if( purgeDays < 1 )
					purgeDays = 1
				end
				Log.debug("Using a purge threshold of #{purgeDays}")

				# Alright, now that we know what threshold to use
				# we need to go over all the pins again and purge
				newPins = []
				for pin in pins
					pin.purgeOldVerifies(purgeDays)
					if( Configuration::DebugUserEnabled )
						pin.purgeDebugVerifies
					end
					if( pin.verifies > 0 )
						newPins.push(pin)
					else
						Log.debug("Purging pin at #{pin.latitude} #{pin.longitude}")
					end
				end

				# If there are any pins left we re-save them to disk
				# But if we deprecated the last one then delete the database
				if( newPins.size == 0 )
					File.unlink(Configuration::PinDir + "/" + zf)
				else
					f.rewind
					f.truncate(f.pos)
					f.write(Zlib::Deflate.deflate(Marshal.dump(newPins)))
				end
			ensure
				f.close
			end
		end
	end

	# Note: This function is for administrators to view the state
	# of the map as a whole, and is not intended for user-use
	def self.getAllPins()
		dbs = Dir.entries(Configuration::PinDir).select do |f|
			(Configuration::PinDir + "/" + f).end_with?(Configuration::PinDBSuffix)
		end
		pins = []
		for file in dbs
			pins += loadPins(file)
		end
		data = []
		for pin in pins
			data += [[pin.latitude, pin.longitude, pin.verifies]]
		end
		return data
	end
end
