//
//  Notifications.h
//  Where Are The Eyes
//
//  Created by Milo Trujillo on 8/5/17.
//  Copyright © 2017 Daylighting Society. All rights reserved.
//

#ifndef Notifications_h
#define Notifications_h

@interface Notifications : NSObject

// Sends an alert with specified text if designated permission is TRUE, or permissionName is nil
// Returns true if the alert is actually sent, false otherwise
+ (bool)notifyAlert:(NSString*)alertTitle message:(NSString*)alertText ifPermission:(NSString*)permissionName;

@end

#endif /* Notifications_h */
