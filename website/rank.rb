#!/usr/bin/env ruby

require_relative 'configuration'
require_relative 'scores'

module Rank
	class Level
		attr_reader :title, :cameras, :users
		def initialize(title, cameras, users)
			@title = title
			@cameras = cameras
			@users = users
		end
	end

	# Returns an up-to-date list of ranks and how many users match each rank
	def self.calculateRanks
		rankList = []
		rankData = File.read(Configuration::RankList).split("\n")
		scores = Scores.getAllScores
		for rank in rankData
			(score,title) = rank.split(",")
			score = score.to_i
			users = 0
			for user in scores
				if( user.cameras >= score )
					users += 1
				end
			end
			rankList << Level.new(title, score, users)
		end
		return rankList
	end

	def self.saveRanks
		rankList = calculateRanks()
		rankCSV = ""
		for rank in rankList
			if( rank.users > 0 ) # Only show attained ranks
				rankCSV << "#{rank.users}, #{rank.cameras}, #{rank.title}\n"
			end
		end
		f = File.open(Configuration::ScoreboardData, "w")
		f.write(rankCSV)
		f.close
	end
end
