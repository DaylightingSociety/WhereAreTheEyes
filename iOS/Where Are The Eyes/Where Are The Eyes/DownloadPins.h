//
//  DownloadPins.h
//  Where Are The Eyes
//
//  Created by Milo Trujillo on 5/31/16.
//  Copyright © 2016 Daylighting Society. All rights reserved.
//

#ifndef DownloadPins_h
#define DownloadPins_h

@import Mapbox;

@interface DownloadPins : NSObject

// Returns an array of pins near the current location
+ (NSArray*)download:(CLLocationCoordinate2D)coord;

@end

#endif /* DownloadPins_h */
