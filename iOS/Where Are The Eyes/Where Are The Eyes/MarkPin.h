//
//  MarkPin.h
//  Where Are The Eyes
//
//  Created by Milo Trujillo on 6/2/16.
//  Copyright © 2016 Daylighting Society. All rights reserved.
//

#ifndef MarkPin_h
#define MarkPin_h

#import "Pin.h"

@interface MarkPin : NSObject

+ (id)markPinAt:(Pin*)p withUsername:(NSString*)username;

@end

#endif /* MarkPin_h */
