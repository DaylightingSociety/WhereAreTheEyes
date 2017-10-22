#!/usr/bin/env ruby

module Configuration
	# Pathnames
	Private = File.dirname(__FILE__) + "/private"
	Public = File.dirname(__FILE__) + "/public"
	Tmp = File.dirname(__FILE__) + "/tmp"
	PostsDirName = "posts"
	PostsDir = Private + "/" + PostsDirName
	PreviewDir = Private + "/preview"
	PinDir = Private + "/pins"
	BackupDir = Private + "/backups"
	ExportDir = Public + "/rawdata"
	ExportImageScript = File.dirname(__FILE__) + "/camimage.py"
	LoginDatabase = Private + "/login.db"
	ScoreDatabase = Private + "/scores.db"
	RankList = Private + "/ranks.csv"
	ScoreboardData = Private + "/scoreboard.csv"
	ExportImagePath = Public + "/currentCameras.png"

	# Logging config
	DebugEnabled = false
	LogName = "Eyes" # Name to use for log identifier

	# Status post config
	FrontPagePostHistory = 3 # How many posts to show on front page
	PostSeparator = "\n<hr>\n"

	# RSS feed config
	Title = "Where are the Eyes?"
	SiteUrl = "eyes.daylightingsociety.org"
	Description = "Watch the state watch you back"

	# Auth configuration
	HashCost = 8
	MaxUserLength = 30
	MaxPassLength = 30
	TokenLength = 30
	MasterPinReadingPassword = ""
	DebugUserEnabled = true
	DebugUsername = ""

	# Rate Limiting configuration
	RateLimitDir = Private + "/ratelimit"
	RateHashFile = RateLimitDir + "/iphash.db"
	RateStackFile = RateLimitDir + "/timestampstack.db"
	RateBlacklistFile = RateLimitDir + "/blacklist.db"
	RatePeriod = 300 # Five minutes, in seconds
	RateThreshold = 50 # Can't mark more than 50 cams in 5 minutes
	RateBlacklistPeriod = 1800 # Half an hour in seconds

	# LanguageConfig
	AcceptedLanguages = ["en", "pt"]
	DefaultLanguage = "en"

	# Cookie (used during registration) config
	CookieSecretPath = Private + "/secret.txt"
	CookieDuration = 600 # Ten minutes, tops

	# Display config
	MinZoom = 10 # Only let the user zoom out to about a view of their city

	# Watchdog Config
	DeprecationCycle = 21600 # seconds (a quarter day)
	BackupCycle = 3600 # Make a backup every hour
	BackupRolloverHour = 4 # When do we rotate backups (4 AM)
	WatchdogProcessName = "WhereAreTheEyes Watchdog"
	WatchdogPIDFile = Tmp + "/watchdog.pid"
	DBSuffix = ".db"

	# Export Config
	ExportEnabled = true
	ExportImageEnabled = true # Requires Python, numpy, matplotlib, etc
	ExportPeriod = 86400 # 24 hours, in seconds

	# Map config
	MaxPinDisplayRadius = 500 # Measured in something
	MaxPinPostRadius = 1000 # Not allowed to post a pin if you're far away
	PinOverlapRadius = 5 # Pins closer than PinOverlapRadius meters are same pin
	PinDBSuffix = ".db"

	# Scoreboard config
	ScoreboardEnabled = true
	ScoreboardPeriod = 3600 # Recalculate scoreboard hourly
end
