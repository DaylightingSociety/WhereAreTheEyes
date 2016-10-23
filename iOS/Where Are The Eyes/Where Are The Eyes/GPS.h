//
//  GPS.h
//  Where Are The Eyes
//
//  Created by Milo Trujillo on 5/30/16.
//  Copyright © 2016 Daylighting Society. All rights reserved.
//

#ifndef GPS_h
#define GPS_h

#import <CoreLocation/CoreLocation.h>
@import Mapbox;

@interface GPS : NSObject <CLLocationManagerDelegate>
{
	CLLocationManager* locationManager;
	MGLMapView* _map;
	BOOL firstLocationKnown;
}
@property CLLocationCoordinate2D lastCoord;
@property NSDate* lastCoordTime;

// Starts locationManager, takes an argument of a map
- (GPS*)init:(MGLMapView*)map;

// Re-downloads pins using the current position
- (id)forcePinUpdate;

// Callback for getting updates
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations;
@end

#endif /* GPS_h */