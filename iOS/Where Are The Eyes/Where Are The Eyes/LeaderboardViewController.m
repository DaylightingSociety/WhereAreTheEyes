//
//  LeaderboardViewController.m
//  Where Are The Eyes
//
//  Created by Milo Trujillo on 7/15/17.
//  Copyright © 2017 Daylighting Society. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LeaderboardViewController.h"

@interface LeaderboardViewController ()



@end



@implementation LeaderboardViewController

// Initial setup code goes here
- (void)viewDidLoad {
	[super viewDidLoad];
}


// Returns to the main view without restarting it
- (IBAction)handleBack:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
