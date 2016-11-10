//
//  Vibrate.m
//  Where Are The Eyes
//
//  Created by Milo Trujillo on 11/1/16.
//  Copyright © 2016 Daylighting Society. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioServices.h>
#import "Vibrate.h"

@implementation Vibrate

+ (void) pulse
{
	// This will vibrate on devices that support it, and *should* be silent otherwise.
	// There is an alternate "AudioServicesPlayAlertSound" that makes a noise
	// if vibration is unavailable.
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

@end
