#!/usr/bin/env ruby

=begin
	This module is responsible for initialization. We had to split up
	initialization from configuration to resolve circular dependency problems.
=end

require 'thread'
require_relative 'configuration'
require_relative 'auth'
require_relative 'scores'
require_relative 'map'
require_relative 'backup'
require_relative 'log'
require_relative 'location'
require_relative 'ratelimit'
require_relative 'export'
require_relative 'rank'

module State
	$secret = ""
	def State.init
		unless( Dir.exists?(Configuration::PinDir) )
			Dir.mkdir(Configuration::PinDir)
		end

		unless( Dir.exists?(Configuration::BackupDir) )
			Dir.mkdir(Configuration::BackupDir)
		end
		Backup.init # Create additional backup subdirs

		unless( Dir.exists?(Configuration::PostsDir) )
			Dir.mkdir(Configuration::PostsDir)
		end

		unless( Dir.exists?(Configuration::PreviewDir) )
			Dir.mkdir(Configuration::PreviewDir)
		end

		unless( Dir.exists?(Configuration::RateLimitDir) )
			Dir.mkdir(Configuration::RateLimitDir)
		end

		unless( Dir.exists?(Configuration::ExportDir) )
			Dir.mkdir(Configuration::ExportDir)
		end

		unless( File.file?(Configuration::LoginDatabase) )
			Auth.createDatabase
		end

		# Initialize the score database
		Scores.init

		# Load the geoip database from disk
		Location.init

		# Set up rate-limiting databases
		RateLimit.init
		
		unless( File.file?(Configuration::CookieSecretPath) )
			Log.error("NO SECRET FILE FOUND. ABORTING START.")
			exit
		end
		$secret = File.read(Configuration::CookieSecretPath)
		if( Configuration::DebugEnabled )
			Log.notice("#{Configuration::Title} initialized (debugging enabled).")
		else
			Log.notice("#{Configuration::Title} initialized.")
		end
	end
	
	private_class_method def State.killWatchdogProcess
		if( File.exists?(Configuration::WatchdogPIDFile) )
			begin
				pid = File.read(Configuration::WatchdogPIDFile).to_i
				if( pid != 0 )
					Process.kill("TERM", pid)
					Log.notice("Killed existing watchdog process during startup #{pid}")
				else
					Log.notice("No watchdog PID found in file, process may already be dead?")
				end
			rescue => e
				Log.warning("Could not kill watchdog process: #{e.message}")
				Log.warning("Kill watchdog backtrace: #{e.backtrace.to_s}")
			end
		end
	end

	private_class_method def State.recordWatchdogPID
		begin
			File.write(Configuration::WatchdogPIDFile, Process.pid.to_s + "\n")
			Log.notice("Recorded watchdog process PID (#{Process.pid.to_s})")
		rescue => e
			Log.warning("Could not record watchdog PID: #{e.message}")
			Log.warning("PID recording backtrace: #{e.backtrace.to_s}")
		end
	end

	private_class_method def State.deprecateCycle
		loop do
			begin
				Log.debug("Initiating deprecation sleep cycle...")
				sleep (Configuration::DeprecationCycle)
				Log.debug("Deprecating pins...")
				Map.deprecatePins
			rescue => e
				Log.warning("Deprecation thread crashed: #{e.message}")
				Log.warning("Deprecation crash backtrace:\n#{e.backtrace.to_s}")
			end
		end
	end

	private_class_method def State.backupCycle
		loop do
			begin
				Log.debug("Initiating backup sleep cycle...")
				sleep (Configuration::BackupCycle)
				Log.debug("Initiating backup...")
				Backup.backupPins
			rescue => e
				Log.warning("Backup thread crashed: #{e.message}")
				Log.warning("Backup crash backtrace:\n#{e.backtrace.to_s}")
			end
		end
	end

	private_class_method def State.ratelimitCycle
		loop do
			begin
				Log.debug("Initiating rate limit sleep cycle...")
				sleep (Configuration::RatePeriod)
				Log.debug("Removing old rate limit data...")
				RateLimit.purgeRecords()
			rescue => e
				Log.warning("Rate limit thread crashed: #{e.message}")
				Log.warning("Rate limit crash backtrace:\n#{e.backtrace.to_s}")
			end
		end
	end

	private_class_method def State.exportCycle
		loop do
			begin
				Log.debug("Initiating export sleep cycle...")
				sleep (Configuration::ExportPeriod)
				path = Export.exportPinsCSV(Time.now.strftime("%Y-%m-%d.csv"))
				if( Configuration::ExportImageEnabled )
					system("#{Configuration::ExportImageScript} #{path} #{Configuration::ExportImagePath}")
				end
				Export.exportPinsKML(Time.now.strftime("%Y-%m-%d.kml"))
			rescue => e
				Log.warning("Export thread crashed: #{e.message}")
				Log.warning("Export thread crash backtrace:\n#{e.backtrace.to_s}")
			end
		end
	end

	private_class_method def State.scoreboardCycle
		loop do
			begin
				Log.debug("Recalculating scoreboard...")
				Rank.saveRanks()
				Log.debug("Initiating scoreboard sleep cycle...")
				sleep (Configuration::ScoreboardPeriod)
			rescue => e
				Log.warning("Scoreboard thread crashed: #{e.message}")
				Log.warning("Scoreboard thread crash backtrace:\n#{e.backtrace.to_s}")
			end
		end
	end

	def State.startWatchdog
		fork do
			$0 = Configuration::WatchdogProcessName
			killWatchdogProcess
			recordWatchdogPID
			Log.notice("Watchdog subprocess started.")
			deprecationThread = Thread.new do deprecateCycle end
			backupThread = Thread.new do backupCycle end
			ratelimitThread = Thread.new do ratelimitCycle end
			exportThread = Thread.new do exportCycle end
			scoreboardThread = Thread.new do scoreboardCycle end

			# To prevent the subprocess from exiting we block the main thread
			deprecationThread.join
			Log.error("Deprecation thread exited infinite loop!")
			backupThread.join 
			ratelimitThread.join
			exportThread.join
		end
	end

	def State.getSecret
		return $secret.clone
	end
end
