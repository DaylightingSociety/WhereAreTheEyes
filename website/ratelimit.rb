#!/usr/bin/env ruby

require_relative 'configuration'
require_relative 'log'

=begin
	This file maintains the rate limiting database, which can determine
	if an IP address has been posting pins too frequently. This is used
	to prevent scripts from annihilating our map, or to prevent users
	from skipping down the road tapping the mark button pointlessly.
=end

module RateLimit
	StackRecord = Struct.new(:timestamp, :ip)

	# Set up empty databases if they don't exist yet
	def self.init()
		unless( File.exists?(Configuration::RateHashFile) )
			db = Hash.new(0)
			f = File.open(Configuration::RateHashFile, "w")
			f.write(Marshal.dump(db))
			f.close
		end
		unless( File.exists?(Configuration::RateStackFile) )
			db = Array.new
			f = File.open(Configuration::RateStackFile, "w")
			f.write(Marshal.dump(db))
			f.close
		end

		unless( File.exists?(Configuration::RateBlacklistFile) )
			db = Hash.new()
			f = File.open(Configuration::RateBlacklistFile, "w")
			f.write(Marshal.dump(db))
			f.close
		end
	end

	# Records than an IP has marked a camera, tracks frequency so we can
	# detect anyone abusing the map and marking cameras everywhere.
	def self.addRecord(ip)
		timestamp = Time.now.to_i
		needToBlacklist = false

		f = File.open(Configuration::RateStackFile, "r+")
		f.flock(File::LOCK_EX)
		db = Marshal.load(f.read)
		db.push(StackRecord.new(timestamp, ip))
		f.seek(0)
		f.write(Marshal.dump(db))
		f.truncate(f.pos)
		f.close

		f = File.open(Configuration::RateHashFile, "r+")
		f.flock(File::LOCK_EX)
		hash = Marshal.load(f.read)
		hash[ip] += 1
		if( hash[ip] > Configuration::RateThreshold )
			needToBlacklist = true
		end
		f.seek(0)
		f.write(Marshal.dump(hash))
		f.truncate(f.pos)
		f.close

		if( needToBlacklist )
			f = File.open(Configuration::RateBlacklistFile, "r+")
			f.flock(File::LOCK_EX)
			blacklist = Marshal.load(f.read)
			blacklist[ip] = timestamp
			f.seek(0)
			f.write(Marshal.dump(blacklist))
			f.truncate(f.pos)
			f.close
		end
	end

	# Returns if a mark should be blocked because the IP Address was abusive
	def self.rateExceeded?(address)
		hash = Marshal.load(File.read(Configuration::RateBlacklistFile))
		return hash.has_key?(address)
	end

	# Remove all records old enough that they don't matter.
	# What "matters" is defined by some constants, but it's around
	# "IP records for the last five minutes, blacklist for 30"
	def self.purgeRecords()
		timestamp = Time.now.to_i

		# This double locking *should not* have a race condition,
		# because anyone that need to access both files will
		# always access the stack first.
		s = File.open(Configuration::RateStackFile, "r+")
		s.flock(File::LOCK_EX)
		h = File.open(Configuration::RateHashFile, "r+")
		h.flock(File::LOCK_EX)
		stack = Marshal.load(s.read)
		newStack = []
		newHash = Hash.new(0)
		for record in stack
			# If the record is less than X seconds old then we care
			if( timestamp - record.timestamp < Configuration::RatePeriod )
				newStack.push(record)
				newHash[record.ip] += 1
			end
		end

		# Write out the new stacks and hashes, with irrelevant data purged
		s.seek(0)
		h.seek(0)
		s.write(Marshal.dump(newStack))
		h.write(Marshal.dump(newHash))
		s.truncate(s.pos)
		h.truncate(h.pos)
		s.close
		h.close

		# Alright, now let's remove anyone that's been sitting in the cage
		# for long enough...
		b = File.open(Configuration::RateBlacklistFile, "r+")
		b.flock(File::LOCK_EX)
		blacklist = Marshal.load(b.read)
		blacklist.delete_if {|ip, time| timestamp - time > Configuration::RateBlacklistPeriod}
		b.seek(0)
		b.write(Marshal.dump(blacklist))
		b.truncate(b.pos)
		b.close
	end
end
