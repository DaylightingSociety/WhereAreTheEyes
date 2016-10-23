//
//  Score.m
//  Where Are The Eyes
//
//  Created by Milo Trujillo on 7/19/16.
//  Copyright © 2016 Daylighting Society. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Score.h"
#import "Constants.h"

@interface Score () {
	int verifications;
	int cameras_marked;
	Boolean wasEnabled;
	NSString* lastUsername;
}
@end

@implementation Score : NSObject

- (Score*)init
{
	self = [super init];
	verifications = 0;
	cameras_marked = 0;
	wasEnabled = false;
	lastUsername = nil;
	return self;
}

// Returns whether scores are currently enabled
- (BOOL) scoresEnabled
{
	Boolean enabled = [[NSUserDefaults standardUserDefaults] boolForKey:kShowScore];
	wasEnabled = enabled;
	return enabled;
}

// Returns if scores were enabled last time we checked
- (BOOL) scoresWereEnabled
{
	return wasEnabled;
}

// Returns if the username has changed since last time we updated our score
- (BOOL) usernameChanged:(NSString*) newUsername
{
	if( lastUsername == nil )
		return true;

	NSLog(@"Checking if username changed. Old name: %@ New name: %@", lastUsername, newUsername);
	return (![lastUsername isEqualToString:newUsername]);
}

- (void) updateScores:(NSString*)username
{
	lastUsername = username;
	NSLog(@"Updating score for user %@", username);
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSString* urlString = [NSString stringWithFormat:@"%@/getScore/%@",kEyesURL, username];
		NSURL* url = [[NSURL alloc] initWithString:urlString];
		
		NSError *error = nil;
		NSStringEncoding encoding = 0;
		
		// Download pin data
		NSString* data = [NSString stringWithContentsOfURL:url usedEncoding:&encoding error:&error];
		
		NSArray* chunks = [data componentsSeparatedByString:@","];
		NSLog(@"Score data received: %@", data);
		@try {
			long cams = [chunks[0] integerValue];
			long vers = [chunks[1] integerValue];
			if( cams >= 0 )
				cameras_marked = (int)cams;
			if( vers >= 0 )
				verifications = (int)vers;
			NSLog(@"Saving as cameras (%d) verifications (%d)", cameras_marked, verifications);

			[[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateScore" object:self];
		}
		@catch (NSException* exception) {
			NSLog(@"Crash handling score data - aborting update.");
		}
	});
}

- (int)getVerifications
{
	return verifications;
}

- (int)getCameras
{
	return cameras_marked;
}

@end
