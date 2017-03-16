#!/usr/bin/env ruby

=begin
	This module provides a thread-safe, process-safe points database.
	It stores how many new cameras and verifications a username is responsible
	for. Usernames are stored in hashed format to make reverse analysis more
	challenging.

	We used SHA256 instead of BCrypt because adding a unique salt and slow
	algorithm would make looking up anyone's score an O(n) operation, and it
	occurs too frequently to incur that cost. This way we maintain the hash 
	table's O(1) performance. We do add a database salt, however, so at least
	a rainbow table attack won't work.

	Points are returned as a 'points' object. This means cameras and 
	verifications can be accessed like:
		Scores.getUserScore(username).cameras
		Scores.getUserScore(username).verifications
=end

require 'securerandom'
require 'digest/sha2'
require 'pstore'
require_relative 'configuration'
require_relative 'log'

class Points
	attr_accessor :cameras
	attr_accessor :verifications
	def initialize(cameras, verifications)
		@cameras = cameras
		@verifications = verifications
	end
end

module Scores
	@@scores = nil
	@@initialized = false

	# Creates a new blank score database if none exists
	def Scores.init()
		@@scores = PStore.new(Configuration::ScoreDatabase)
		@@scores.transaction do
			# Create a database-wide salt. This will protect us from hash
			# brute-forcing without incurring a significant performance penalty.
			if( @@scores['salt'] == nil )
				@@scores['salt'] = SecureRandom.hex
			end
		end
		@@initialized = true
		Log.notice("Score database initialized.")
	end

	def Scores.hashUsername(username, salt)
		return (Digest::SHA2.new << (username + salt)).to_s
	end

	# Returns a Points object or nil if user doesn't exist
	def Scores.getUserScore(username)
		scores = nil
		@@scores.transaction do
			name = hashUsername(username, @@scores['salt'])
			result = @@scores[name]
			if( result != nil )
				scores = result.clone
			end
		end
		return scores
	end

	def Scores.addCamera(username)
		@@scores.transaction do
			name = hashUsername(username, @@scores['salt'])
			oldVal = @@scores[name]
			if( oldVal == nil )
				@@scores[name] = Points.new(1, 0)
			else
				oldVal.cameras += 1
				@@scores[name] = oldVal
			end
		end
	end

	def Scores.removeCamera(username)
		@@scores.transaction do
			name = hashUsername(username, @@scores['salt'])
			oldVal = @@scores[name]
			if( oldVal == nil )
				return
			else
				oldVal.cameras -= 1
				if( oldVal.cameras < 0 )
					oldVal.cameras = 0
				end
				@@scores[name] = oldVal
			end
		end
	end

	def Scores.addVerification(username)
		@@scores.transaction do
			name = hashUsername(username, @@scores['salt'])
			oldVal = @@scores[name]
			if( oldVal == nil )
				@@scores[name] = Points.new(0, 1)
			else
				oldVal.verifications += 1
				@@scores[name] = oldVal
			end
		end
	end

	def Scores.removeVerification(username)
		@@scores.transaction do
			name = hashUsername(username, @@scores['salt'])
			oldVal = @@scores[name]
			if( oldVal == nil )
				return
			else
				oldVal.verifications -= 1
				if( oldVal.verifications < 0 )
					oldVal.verifications = 0
				end
				@@scores[name] = oldVal
			end
		end
	end
end
