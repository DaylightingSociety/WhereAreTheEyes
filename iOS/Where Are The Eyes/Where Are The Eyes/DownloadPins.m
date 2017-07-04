//
//  DownloadPins.m
//  Where Are The Eyes
//
//  Created by Milo Trujillo on 5/31/16.
//  Copyright © 2016 Daylighting Society. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadPins.h"
#import "Pin.h"
#import "Constants.h"

@implementation DownloadPins

+ (NSArray*)download:(CLLocationCoordinate2D)coord
{
	NSString* urlString = [NSString stringWithFormat:@"%@/getPins/%d/%d/9",kEyesURL, (int)(coord.latitude + 0.5), (int)(coord.longitude + 0.5)];
	NSURL* url = [[NSURL alloc] initWithString:urlString];
	
	NSError *error = nil;
	NSStringEncoding encoding = 0;
	
	// Download pin data
	NSString* data = [NSString stringWithContentsOfURL:url usedEncoding:&encoding error:&error];
	
	// And start parsing
	NSMutableArray* pins = [[NSMutableArray alloc] init];
	NSArray* lines = [data componentsSeparatedByString:@"\n"];
	for( NSString* line in lines )
	{
		// Split up the CSV, only take latitude and longitude out
		NSArray* chunks = [line componentsSeparatedByString:@","];
		if( chunks.count >= 2 )
		{
			float lat = [chunks[0] floatValue];
			float lon = [chunks[1] floatValue];
			int verifications = [chunks[2] intValue];
			Pin* c = [[Pin alloc] initLatitude:lat longitude:lon confirmations:verifications type:UNKNOWN];
			[pins addObject:c];
		}
	}
	
	return pins;
}

@end
