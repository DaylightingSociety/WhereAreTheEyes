#!/usr/bin/env ruby

require 'geoip'

require_relative 'configuration'

=begin
	This module is responsible for everything to do with location and distance.
	It calculates the distance between two GPS coordinates, or returns the
	approximate GPS coordinates of an IP address to perform reverse lookups.
=end

module Location

	def self.init
		@@geoip = GeoIP.new(Configuration::GeoIPDatabase)
	end

	# Returns whether an IP address is close enough to a latitude
	# longitude that it's feasible their location is correct.
	def self.ipInRange?(ip, lat, lon)
		(physical_lat, physical_lon) = getCoordinatesOfIP(ip)
		if( physical_lat.nil? or physical_lon.nil? )
			return false
		end
		dist = getDistance(lat, lon, physical_lat, physical_lon)
		if( dist > Configuration::IPProximityThreshold )
			return false
		end
		return true
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

	# Returns (latitude, longitude) if address is valid
	# Returns (nil, nil) if we can't resolve it
	def self.getCoordinatesOfIP(address)
		lookup = @@geoip.city(address)
		if( lookup.nil? )
			return [nil, nil]
		else
			return [lookup.latitude, lookup.longitude]
		end		
	end
end
