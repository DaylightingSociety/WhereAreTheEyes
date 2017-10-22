#!/usr/bin/env ruby

require 'date'
require 'fileutils'
require_relative 'configuration'
require_relative 'log'

=begin
	This module is responsible for managing backups of pin data.
	This means backing up new data, rotating old backups, and making
	sure nothing goes wrong.

	This module is triggered by the watchdog process from state.rb
=end

module Backup
	# Initialization makes subfolders for storing backups
	# In principle it should also verify that we have write permision
	# to all of them, but that's not a scenario we're anticipating on
	# our servers.
	def Backup.init
		backupdir = Configuration::BackupDir
		unless( Dir.exists?(backupdir + "/hourly") )
			Dir.mkdir(backupdir + "/hourly")
		end

		unless( Dir.exists?(backupdir + "/daily") )
			Dir.mkdir(backupdir + "/daily")
		end

		unless( Dir.exists?(backupdir + "/monthly") )
			Dir.mkdir(backupdir + "/monthly")
		end
	end

	# This creates a new hourly folder if needed, or clears the old one
	# if it's occupied. Occupied folders can be flushed because they
	# should already have been backed up to daily.
	private_class_method def Backup.createHourlyFolder(time)
		hour = time.hour.to_s
		dirname = Configuration::BackupDir + "/hourly/" + hour
		unless( Dir.exists?(dirname) )
			Dir.mkdir(dirname)
		else
			# Clear the old backups as we go
			files = Dir.entries(dirname).select{ |f| f.end_with?(Configuration::PinDBSuffix) }
			for file in files
				File.unlink(dirname + "/" + file)
			end
		end
		return dirname
	end

	# Daily folders exist for one month, so we use the day number
	private_class_method def Backup.createDailyFolder(time)
		day = time.day.to_s
		dirname = Configuration::BackupDir + "/daily/" + day
		unless( Dir.exists?(dirname) )
			Dir.mkdir(dirname)
		end
		return dirname
	end

	# "monthly" folders exist forever and therefore have year appended
	private_class_method def Backup.createMonthlyFolder(time)
		year = time.year.to_s
		month = Date::MONTHNAMES[Date.today.month]
		dirname = Configuration::BackupDir + "/monthly/" + month + year
		unless( Dir.exists?(dirname) )
			Dir.mkdir(dirname)
		end
		return dirname
	end

	# Saves the current pin database state into an hourly backup folder
	# Also save the login database
	private_class_method def Backup.createNewSnapshot(time)
		dstFolder = createHourlyFolder(time)
		pinFiles = Dir.entries(Configuration::PinDir).select do |f| 
			f.end_with?(Configuration::PinDBSuffix)
		end
		for file in pinFiles
			# First we lock each database so the map code can't corrupt our copy
			f = nil
			begin
				f = File.open(Configuration::PinDir + "/" + file, "r")
				f.flock(File::LOCK_EX)
				# Now let's copy the file, then release the lock
				src = Configuration::PinDir + "/" + file
				dst = dstFolder + "/" + file
				FileUtils.cp(src, dst)
			ensure
				f.close
			end
		end
		begin
			loginDB = Configuration::LoginDatabase
			f = File.open(loginDB, "r")
			f.flock(File::LOCK_EX)
			fname = File.basename(loginDB)
			FileUtils.cp(loginDB, dstFolder + "/" + fname)
		ensure
			f.close
		end
	end

	# Moves backups from the daily folder to its final home
	# in the monthly folder. Then we purge the daily backups.
	# At present it preserves the 1st backup of the month, since
	# our hourly backups will be close to the end of the month.
	private_class_method def Backup.migrateDailyToMonth(dest)
		entries = Dir.entries(Configuration::BackupDir + "/daily")
		entries.reject!{|f| f.start_with?(".") }.sort_by!(&:to_i)
		src = Configuration::BackupDir + "/daily/" + entries.shift
		Log.debug("Backing up data from #{src} to monthly.")
		files = Dir.entries(src).select{|f| f.end_with?(Configuration::PinDBSuffix)}
		for file in files
			FileUtils.cp(src + "/" + file, dest + "/" + file)
		end

		# We've made our backup, now purge the old daily folders
		dailyDir = Configuration::BackupDir + "/daily"
		dailyDirs = Dir.entries(dailyDir).reject { |f| f.start_with?(".") }
		for dir in dailyDirs
			dst = dailyDir + "/" + dir
			if( File.directory?(dst) )
				FileUtils.remove_dir(dst)
			end
		end
	end

	# Here we copy the last hour before the rotation to the daily log.
	# If you want to go back earlier than that then look at the hourly
	# logs that haven't been overwritten yet. Not old enough? Use older
	# daily logs.
	private_class_method def Backup.migrateHourlyToDaily(time)
		hour = time.hour
		hourlyDir = Configuration::BackupDir + "/hourly"
		Log.debug("Creating daily backup.")

		# This little dance finds the most recent hourly log folder
		entries = Dir.entries(hourlyDir).reject{ |d| d.start_with?(".") }
		viable = entries.reject{ |d| d.to_i >= hour }.sort_by(&:to_i)
		src = nil
		if( viable.size != 0 )
			src = viable.pop
		else
			src = entries.sort_by(&:to_i).pop
		end
		if( src == nil )
			Log.error("Unable to find hourly backups to migrate to daily backups!")
			return
		end

		# Now we do the actual migration
		dst = createDailyFolder(time)
		for file in Dir.entries(hourlyDir + "/" + src)
			if( file.end_with?(Configuration::DBSuffix) )
				FileUtils.cp("#{hourlyDir}/#{src}/#{file}", "#{dst}/#{file}")
			end
		end
	end

	# Rotates to monthly backups at the start of the month
	# Always rotates hourly backups to daily ones.
	private_class_method def Backup.rotateBackups(time)
		# We rollover the days first if necessary, *then* handle the hours
		if( time.day == 1 )
			Log.notice("Creating monthly backup...")
			dest = createMonthlyFolder(time)
			migrateDailyToMonth(dest)
		end
		migrateHourlyToDaily(time)
	end

	# This is the only regularly called external method. It backs up pins
	# each hour and rotates backups when appropriate.
	def Backup.backupPins
		time = Time.new
		if( time.hour == Configuration::BackupRolloverHour )
			rotateBackups(time)
		end
		createNewSnapshot(time)
	end
end
