//
//  AboutViewController.h
//  Where Are The Eyes
//
//  Created by Milo Trujillo on 6/27/16.
//  Copyright © 2016 Daylighting Society. All rights reserved.
//

#ifndef AboutViewController_h
#define AboutViewController_h

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController {	
	
}

@property (weak, nonatomic) IBOutlet UITextView *aboutText;


- (IBAction)handleBack:(id)sender;

@end

#endif /* AboutViewController_h */
