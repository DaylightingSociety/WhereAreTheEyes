# Where are the Eyes?

Where are the Eyes is a program for detecting and mapping surveillance cameras. Users mark cameras on their phone as they walk past them, and build a shared global map of surveillance.

Our hope is that Where are the Eyes will be widely adopted and used to help activists in two ways: to increase awareness of surveillance and authoritarian practices, and to plan activist movements.

You can read [more on our website!](https://eyes.daylightingsociety.org)

## Public Repository

The master branch of this repo represents the code currently on the App and Play Stores, as well as F-Droid. Code we are currently developing will be on other branches.

### Is anything different between this code and what is on my phone?

The apps on the App and Play stores will be cryptographically signed, but the code is identical.

## How do I build *Where are the Eyes*?

### Android

* Get a recent version of [Android Studio](https://developer.android.com/studio/index.html) and load the project in the 'Android' folder

* You will need to create an account with [MapBox](https://www.mapbox.com/) and put your API key in Constants.java

### iOS

* Get a recent version of [XCode](https://developer.apple.com/xcode/), and load the project in the 'iOS/Where are the Eyes' folder

* You will need to create an account with [MapBox](https://www.mapbox.com/) and put your API key in Info.plist

* You will also need to download the [MapBox framework](https://www.mapbox.com/ios-sdk/) and put it inside the project folder

### Server

Using your own *Where are the Eyes* server is not recommended because you will not see map updates from other users. The code is provided here so you can see exactly how your data is used once it reaches our servers.

If you want to run the server code for testing, we built it to be embedded in Apache using [Passenger](https://www.phusionpassenger.com/) and [Sinatra](http://www.sinatrarb.com/), along with a few dependencies specified in the Gemfile.

## How can I contribute?

We love bug reports, feature suggestions, and code contributions! We will not accept pull requests to master, since that code represents what is currently released on the App and Play stores.

## License

All the *Where are the Eyes* code and assets are released under the BSD 3-clause license. Read more in the 'LICENSE' file.

## Attribution

All button icons and image assets came from [Open Iconic](http://useiconic.com/open) (specifically version 1.1.1) under the MIT license. The only exceptions are the app logo itself, the camera marker image, and our media posters, created by the Daylighting Society.
