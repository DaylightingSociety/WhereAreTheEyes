#!/bin/sh

# This script launches the web server in debugging mode
# This is intended for development, if you are deploying live it is 
# expected you will embed inside Apache/NGINX with Passenger!

if [ $# -ne 1 ]; then
	echo "USAGE: $0 <port>"
	exit
fi

rackup -E development -p $1
