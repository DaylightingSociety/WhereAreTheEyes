//
//  GPS.m
//  Where Are The Eyes
//
//  Created by Milo Trujillo on 5/30/16.
//  Copyright © 2016 Daylighting Society. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "GPS.h"
#import "DownloadPins.h"
#import "Coord.h"
#import "Constants.h"

// Note to self: To prompt the user to re-enable location services just call
// any location functions *without* checking whether they're enabled with
// locationServicesEnabled from CLLocationManager.

@implementation GPS

- (GPS*)init:(MGLMapView*)map {
	self = [super init];
	firstLocationKnown = NO;
	
	// Init the locationManager
	locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
	
	// Copy in the mapview reference so we can add pins to it later
	_map = map;
	
	// For most events we only need a rough location, kilometer is good enough
	// Unfortunately when marking new pins we need precise location,
	// and until we figure out how to switch the accuracy when needed
	// we'll just have to leave it on high-power mode.
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	// Only update me when the user has moved 500 meters or so
	// Again, until we learn how to ask for precise data before a pin drop
	// we have to go hardcore and get precise data all the time.
	locationManager.distanceFilter = 3;
	// Aaaand start.
	[locationManager requestWhenInUseAuthorization];
	[locationManager startUpdatingLocation];
	NSLog(@"GPS Initialized");
	
	return self;
}

- (void)updateMap:(NSArray*)pins
{
	// Remove old pins in case they've been purged
	[_map removeAnnotations:[_map annotations]];
	for( Coord* pin in pins)
	{
		@try {
			// Convert from latitude / longitude to a MapBox coordinate
			MGLPointAnnotation *point = [[MGLPointAnnotation alloc] init];
			point.coordinate = CLLocationCoordinate2DMake(pin.latitude, pin.longitude);
			point.title = [NSString stringWithFormat:@"Confirmations: %d", pin.verifications];
			
			// Add the pin to the map
			[_map addAnnotation:point];
		}
		@catch( NSException* e )
		{
			NSLog(@"Problem displaying pin!");
			NSLog(@"Error on pin lat %f lon %f", pin.latitude, pin.longitude);
		}
	}
}

- (id)forcePinUpdate
{
	CLLocation* c = [[CLLocation alloc] initWithLatitude:self.lastCoord.latitude longitude:self.lastCoord.longitude];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[self updatePins:c];
	});
	return nil;
}

- (void)updatePins:(CLLocation*)ping
{
	CLLocationCoordinate2D coord = ping.coordinate;
	NSArray* pins = [DownloadPins download:coord];
	NSLog(@"Downloaded %lu pins", [pins count]);
	
	// Now that we have our pins, add them to the map on the main thread
	[self performSelectorOnMainThread:@selector(updateMap:) withObject:pins waitUntilDone:NO];
}

- (void)centerMapOn:(CLLocation*)ping
{
	[_map setCenterCoordinate:ping.coordinate];
	[_map setZoomLevel:12.0];
}

// Wait for location callbacks
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
	// Get the current position and timestamp
	CLLocation* ping = [locations lastObject];
	CLLocationCoordinate2D coord = ping.coordinate;
	NSDate* now = [NSDate date];
	
	CLLocation* lastPing = nil;
	if( firstLocationKnown )
		lastPing = [[CLLocation alloc] initWithCoordinate:_lastCoord altitude:1 horizontalAccuracy:1 verticalAccuracy:-1 timestamp:now];
	
	//NSLog(@"%@", ping);
	NSLog(@"GPS ping: Latitude %f Longitude %f", coord.latitude, coord.longitude);
	
	// If this is our first ping, or we're far from our last ping, or it's been a long time
	// Then add a 'download pins task' to the threadpool.
	if( !firstLocationKnown
	   || [now timeIntervalSinceDate:_lastCoordTime] > kDownloadPinsTimeThreshold
	   || [ping distanceFromLocation:lastPing] > kDownloadPinsDistanceThreshold )
	{
		// On a background thread go download pins and update the map
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSLog(@"Creating thread to download new pins...");
			[self updatePins:ping];
		});
	}

	// This explicitly creates a new thread, the above uses GCD's threadpool
	//[self performSelectorInBackground:@selector(updatePins:) withObject:ping];
	
	// Now update our last coordinates and timestamp.
	[self setLastCoord:coord];
	[self setLastCoordTime:now];
	
	if( !firstLocationKnown )
	{
		firstLocationKnown = YES;
		[self performSelectorOnMainThread:@selector(centerMapOn:) withObject:ping waitUntilDone:NO];
	}
}

@end
