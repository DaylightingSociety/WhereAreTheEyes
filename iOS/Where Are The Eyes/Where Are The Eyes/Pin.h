//
//  Pin.h
//  Where Are The Eyes
//
//  Created by Milo Trujillo on 5/31/16, (renamed from Coord.h on 6/20/17).
//  Copyright © 2016 Daylighting Society. All rights reserved.
//

#ifndef Pin_h
#define Pin_h
@import Mapbox;

typedef enum cameraTypes : NSUInteger {
	UNKNOWN,
	DOME,
	SWIVEL,
	FIXED
} CameraType;

@interface Pin : MGLPointAnnotation

@property float latitude;
@property float longitude;
@property int verifications;
@property CameraType type;

- (Pin*)initLatitude:(float)lat longitude:(float)lon confirmations:(int)verifications type:(CameraType)camType;

@end

#endif /* Pin_h */
