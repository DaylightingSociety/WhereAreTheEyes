//
//  Notifications.m
//  Where Are The Eyes
//
//  Created by Milo Trujillo on 8/5/17.
//  Copyright © 2017 Daylighting Society. All rights reserved.
//

@import UserNotifications;
#import <Foundation/Foundation.h>
#import "Notifications.h"

@implementation Notifications

+ (bool)notifyAlert:(NSString*)alertTitle message:(NSString*)alertText ifPermission:(NSString*)permissionName
{
	NSLog(@"Asked to create an alert with title '%@'", alertTitle);
	// Check permissions, if we were asked to
	if( permissionName != nil )
	{
		Boolean enabled = [[NSUserDefaults standardUserDefaults] boolForKey:permissionName];
		if( ! enabled )
			return false;
	}
	
	// We have permission or don't need it - try to send the alert
	UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
	[center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
		if (settings.authorizationStatus == UNAuthorizationStatusAuthorized)
		{
			UNMutableNotificationContent* content = [UNMutableNotificationContent new];
			content.title = alertTitle;
			content.body = alertText;
			NSString *identifier = @"LocalNotification";
			UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier
																				  content:content
																				  trigger:nil];
			[center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
				if (error != nil) {
					NSLog(@"Could not add notification request: %@", error);
				}
			}];
		}
	}];
	return true;
}

@end
