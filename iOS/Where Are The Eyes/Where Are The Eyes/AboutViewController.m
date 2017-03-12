//
//  AboutViewController.m
//  Where Are The Eyes
//
//  Created by Milo Trujillo on 6/27/16.
//  Copyright © 2016 Daylighting Society. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AboutViewController.h"

@interface AboutViewController ()



@end



@implementation AboutViewController

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
