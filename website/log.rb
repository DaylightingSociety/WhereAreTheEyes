require 'syslog'

require_relative 'configuration'

=begin
	This module is mostly a wrapper around syslog, though it also
	toggles debugging messages based on global configuration.

	Some day we may want to swap out syslog for some file-based logging 
	or network logging, at which point we'll be greatful for this wrapper.
=end

module Log
	def self.init()
		options = Syslog::LOG_PID | Syslog::LOG_CONS | Syslog::LOG_NDELAY
		Syslog.open(Configuration::LogName, options, Syslog::LOG_DAEMON)
	end

	def self.alert(msg)
		Syslog.log(Syslog::LOG_ALERT, msg.to_s)
	end

	def self.warning(msg)
		Syslog.log(Syslog::LOG_WARNING, msg.to_s)
	end

	def self.error(msg)
		Syslog.log(Syslog::LOG_ERR, msg.to_s)
	end

	def self.notice(msg)
		Syslog.log(Syslog::LOG_NOTICE, msg.to_s)
	end

	def self.debug(msg)
		if( Configuration::DebugEnabled )
			Syslog.log(Syslog::LOG_DEBUG, msg.to_s)
		end
	end
end
