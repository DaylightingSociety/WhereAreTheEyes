#!/usr/bin/env bash

# Set up a few shorthand variables
DIR=$(dirname "$SCRIPT")
WEB="$DIR/website"
IOS_CODE="$DIR/iOS/Where Are The Eyes/Where Are The Eyes"
IOS_PROJ="$DIR/iOS/Where Are The Eyes/Where Are The Eyes.xcodeproj"
ANDROID="$DIR/Android"
ANDROID_CODE="$ANDROID/app/src/main/java/org/daylightingsociety/wherearetheeyes"

echo "Detected paths:"
echo "WEB = $WEB"
echo "IOS_CODE = $IOS_CODE"
echo "IOS_PROJ = $IOS_PROJ"
echo "ANDROID = $ANDROID"
echo "ANDROID_CODE = $ANDROID_CODE"
echo ""

echo "Clearing website debugging information..."
sed -i -e 's/MasterPinReadingPassword.*$/MasterPinReadingPassword = ""/' $WEB/configuration.rb
sed -i -e 's/DebugUsername.*$/DebugUsername = ""/' $WEB/configuration.rb

echo "Clearing iOS Xcode junk..."
rm -rf "${IOS_PROJ}/project.xcworkspace/"
rm -rf "${IOS_PROJ}/xcuserdata"

# For iOS we need to match two lines of a plist, but "sed" doesn't support
# matching across multiple lines. Here goes some Perl nastiness...
echo "Clearing iOS API token..."
perl -0 -p -i -e 's/MGLMapboxAccessToken.*?<\/string>/MGLMapboxAccessToken<\/key>\n\t<string>CENSORED<\/string>/s' "${IOS_CODE}/Info.plist"

echo "Clearing Android Studio junk..."
rm -rf $ANDROID/build/*
rm -rf $ANDROID/local.properties
rm -rf $ANDROID/app/*apk
rm -rf $ANDROID/app/proguard*
rm -rf $ANDROID/app/build/*
rm -rf $ANDROID/projectFilesBackup
rm -rf $ANDROID/.idea/workspace.xml
rm -rf $ANDROID/.idea/libraries

echo "Clearing Android API token..."
sed -i -e 's/APIKEY.*/APIKEY = "CENSORED";/' $ANDROID_CODE/Constants.java

echo "Clearing sed backup files..."
find "${DIR}" -name "*-e" -exec rm {} \;

echo "Clearing OSX filesystem cache..."
find "${DIR}" -name ".DS_Store" -exec rm {} \;

echo ""
echo "If the above commands finished without error you are clear to push to the public branch."
