//
//  AppDelegate.m
//  Where Are The Eyes
//
//  Created by Milo Trujillo on 3/23/16.
//  Copyright © 2016 Daylighting Society. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "Constants.h"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Setting 'Default Value' in the Settings.bundle is purely cosmetic, we have to set the default
	// values *here* for them to have any effect. Note that enabling Mapbox metrics by default is required
	// by their terms of service.
	NSDictionary *userDefaultsDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
										  [NSNumber numberWithBool:YES], kConfirmMarkingCameras,
										  [NSNumber numberWithBool:NO], kShowScore,
										  [NSNumber numberWithBool:YES], kMapboxMetrics,
										  [NSNumber numberWithBool:NO], kTapToMark,
										  kMapThemeLight, kMapTheme,
										  kMapTrackPosition, kMapTracking,
										  nil];
	[[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsDefaults];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	
	// In this case we want to re-center the map on our current location
	ViewController* mainController = (ViewController*)  self.window.rootViewController;
	[mainController recenterMap];
	[mainController viewDidAppear:false]; // Reconfigure UI in case settings have changed
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
