//
//  ViewController.h
//  Where Are The Eyes
//
//  Created by Milo Trujillo on 3/23/16.
//  Copyright © 2016 Daylighting Society. All rights reserved.
//

#import "GPS.h"
#import "Score.h"
@import Mapbox;

@interface ViewController : UIViewController <MGLMapViewDelegate> {
	GPS* gps;
	Score* scores;
	UIView* box;
}

- (IBAction)openSettings:(id)sender;
- (IBAction)eyePressed:(id)sender;
- (IBAction)personPressed:(id)sender;
- (void)recenterMapWithAnimation:(Boolean)animated;

@end
