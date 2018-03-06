#require 'pathname'
require 'bcrypt'
require 'digest'
require 'zlib'
require 'set'

require_relative 'configuration'

=begin
	This file handles all authentication for clients. Note that we store only
	a hash of the username. This means we have no idea who our users are, and
	can only check if they have valid login credentials.

	Credentials are stored with bcrypt.

	Writing to the database *should* be thread/process safe, we're using flock
	with an exclusive lock before any write operations.
=end

AuthFile = Configuration::LoginDatabase

class Account
	def initialize(username)
		@creds = Account.hash(username)
	end

	def Account.hash(username)
		salt = File.read(Configuration::CookieSecretPath)
		Digest::SHA256.digest(salt + username)
	end

	def bcryptCorrectLogin?(username)
		return @creds == (username) # Isn't BCrypt awesome? Overloads comparison
	end
end

module Auth

	def Auth.createDatabase
		auth = Set.new
		f = File.open(AuthFile, "w")
		f.puts(Zlib::Deflate.deflate(Marshal.dump(auth)))
		f.close
	end

	# Adds an account to the database, and locks the file so we cannot add
	# multiple accounts at the same time and corrupt the database
	def Auth.addAccount(username)
		f = File.open(AuthFile, "r+")
		f.flock(File::LOCK_EX)
		auth = Marshal.load(Zlib::Inflate.inflate(f.read))
		auth.add(Account.new(username))
		f.rewind
		f.truncate(f.pos)
		f.puts(Zlib::Deflate.deflate(Marshal.dump(auth)))
		f.close
	end

	def Auth.validLogin?(username)
		if( Configuration::DebugUserEnabled and username == Configuration::DebugUsername )
			return true
		end

		f = File.open(AuthFile, "r")
		auth = Marshal.load(Zlib::Inflate.inflate(f.read))
		f.close

		acct = Account.new(username)
		if( auth.include?(acct) )
			return true
		end

		# Alright, let's check the legacy database, too
		if( File.exists?(Configuration::LoginLegacyDatabase) )
			f = File.open(AuthFile, "r")
			auth = Marshal.load(Zlib::Inflate.inflate(f.read))
			f.close
			
			for act in auth
				if( act.correctLogin?(username) )
					return true
				end
			end
		end

		return false
	end
end

get '/register' do
	token = ""
	Configuration::TokenLength.times do token += rand(97 .. 122).chr end
	session['token'] = token
	erb :register, :locals => {:token => token}
end

get '/registrationDisabled' do
	erb :registrationDisabled
end

post '/register' do
	#redirect '/registrationDisabled' # Comment out this line to enable registration
	username = params['username']
	notbot = params[session['token']]
	maxuserlen = Configuration::MaxUserLength
	if( notbot == nil || notbot == false )
		erb :register, :locals => {:errorMsg => "Bots are not allowed! Please check the 'Are you human' box.", :token => session['token']}
	elsif( username.length < 1 )
		erb :register, :locals => {:errorMsg => "Username must be at least one letter long!", :token => session['token']}
	elsif( username.match(/[^A-Za-z0-9_]/) )
		erb :register, :locals => {:errorMsg => "Username may not contain characters besides A-Za-z0-9_", :token => session['token']}
	elsif( username.size > maxuserlen )
		erb :register, :locals => {:errorMsg => "Username may not exceed #{maxuserlen} characters!", :token => session['token']}
	else
		begin
			Auth.addAccount(username)
			session.clear
			erb :registeredAccount
		rescue Exception => e
			return e.message
		end
	end
end
