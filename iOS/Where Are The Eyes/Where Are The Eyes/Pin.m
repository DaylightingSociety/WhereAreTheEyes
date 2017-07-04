//
//  Pin.m
//  Where Are The Eyes
//
//  Created by Milo Trujillo on 5/31/16, (renamed from Coord.m on 6/20/17).
//  Copyright © 2016 Daylighting Society. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Pin.h"

@implementation Pin

- (Pin*)initLatitude:(float)lat longitude:(float)lon confirmations:(int)verifications type:(CameraType)camType
{
	self = [super init];
	
	[self setLatitude:lat];
	[self setLongitude:lon];
	[self setVerifications:verifications];
	[self setType:camType];
	
	// Compatibility with MGLPointAnnotation
	[self setCoordinate:CLLocationCoordinate2DMake(lat, lon)];
	[self setTitle:[NSString stringWithFormat:@"Confirmations: %d", verifications]];
	
	return self;
}

@end
