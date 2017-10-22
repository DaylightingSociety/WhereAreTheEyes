#!/usr/bin/env ruby

require_relative 'configuration'

=begin
	This module is responsible for everything to do with location and distance.
	It calculates the distance between two GPS coordinates
=end

module Location
	def self.init
	end

	# Returns distance in meters between two GPS coordinates
	# This implementation of the Haversine formula gratefully taken
	# from Stack Overflow: https://stackoverflow.com/questions/12966638
	def self.getDistance(lat1, lon1, lat2, lon2)
		rad_per_deg = Math::PI/180  # PI / 180
		rkm = 6371                  # Earth radius in kilometers
		rm = rkm * 1000             # Radius in meters

		dlat_rad = (lat2-lat1) * rad_per_deg  # Delta, converted to rad
		dlon_rad = (lon2-lon1) * rad_per_deg

		lat1_rad = lat1 * rad_per_deg
		lat2_rad = lat2 * rad_per_deg
		lat1_lon = lon1 * rad_per_deg
		lat2_lon = lon2 * rad_per_deg

		a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
		c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))

		rm * c # Delta in meters
	end
end
