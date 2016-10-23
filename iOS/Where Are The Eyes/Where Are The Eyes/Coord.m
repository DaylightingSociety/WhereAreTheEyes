//
//  Coord.m
//  Where Are The Eyes
//
//  Created by Milo Trujillo on 5/31/16.
//  Copyright © 2016 Daylighting Society. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Coord.h"

@implementation Coord

- (Coord*)initLatitude:(float)lat longitude:(float)lon confirmations:(int)verifications
{
	[self setLatitude:lat];
	[self setLongitude:lon];
	[self setVerifications:verifications];
	
	return self;
}

@end