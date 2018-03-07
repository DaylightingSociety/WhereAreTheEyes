//
//  UnmarkPin.m
//  Where Are The Eyes
//
//  Created by Milo Trujillo on 10/31/16.
//  Copyright © 2016 Daylighting Society. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UnmarkPin.h"
#import "Constants.h"
#import "Vibrate.h"
#import "Notifications.h"

@implementation UnmarkPin

+ (id)unmarkPinAt:(Pin*)p withUsername:(NSString*)username
{
	NSLog(@"Unmarking pin at lat:%f lon:%f with username %@", p.latitude, p.longitude, username);
	[Vibrate pulse]; // Let the user know their unmark request has been noticed
	
	// Create some HTTP objects we'll need later
	NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
	NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
	
	// Set the URL and create an HTTP request
	NSString* unmarkUrl = [kEyesURL stringByAppendingString:@"/unmarkPin"];
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:unmarkUrl]];
	
	// Specify that it will be a POST request
	[request setHTTPMethod:@"POST"];
	
	// Setting a timeout
	[request setTimeoutInterval:kPostTimeout];
	
	// Convert your data and set your request's HTTPBody property
	NSString* data = [NSString stringWithFormat:@"username=%@&latitude=%f&longitude=%f", username, p.latitude, p.longitude];
	
	// Set the size of the request
	[request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[data length]] forHTTPHeaderField:@"Content-length"];
	
	// Now set its contents
	NSData* requestBodyData = [data dataUsingEncoding:NSUTF8StringEncoding];
	[request setHTTPBody:requestBodyData];
	
	// This might take a while on a slow network connection or pin-riddled area.
	// Fire up the spinner
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	// Prepare the request and its response handler
	NSURLSessionUploadTask* httpReq = [session uploadTaskWithRequest:request fromData:requestBodyData completionHandler:^(NSData * _Nullable returnData, NSURLResponse * _Nullable _, NSError * _Nullable error) {
		NSString* response = [[NSString alloc] initWithBytes:[returnData bytes] length:[returnData length] encoding:NSUTF8StringEncoding];
		
		NSLog(@"Response from unmarking pin: %@", response);
		[self parseResponse:response];
	}];

	[httpReq resume]; // Actually send the request
	
	// We're done - network activity spinner can go away
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	return nil;
}

// Reads the server response, and on an error creates an alert box on the main thread.
+ (void)parseResponse:(NSString*)response
{
	// In an error we dispatch a message to the main ViewController, and it displays the errors on the main thread.
	if( [response isEqualToString:@"ERROR: Invalid login\n"] )
		[[NSNotificationCenter defaultCenter] postNotificationName:@"InvalidLogin" object:self];
	else if( [response isEqualToString:@"ERROR: Geoip out of range\n"] )
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CameraOutOfRange" object:self];
	else if( [response isEqualToString:@"ERROR: Rate limit exceeded\n"] )
		[[NSNotificationCenter defaultCenter] postNotificationName:@"RateLimitError" object:self];
	else if( [response isEqualToString:@"ERROR: Permission denied\n"] )
		[[NSNotificationCenter defaultCenter] postNotificationName:@"PermissionDeniedUnmarkingCamera" object:self];
	else if( [response hasPrefix:@"ERROR:"] )
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ErrorUnmarkingCamera" object:self];
	else if( [response hasPrefix:@"SUCCESS"] )
		[Notifications notifyAlert:@"Camera unmarked successfully" message:@"Thank you for your contribution" ifPermission:kShowMarkingNotifications];
	else
		NSLog(@"I got an unmark pin response I don't understand: %@", response);
}

@end
