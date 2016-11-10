//
//  UnmarkPin.h
//  Where Are The Eyes
//
//  Created by Milo Trujillo on 10/31/16.
//  Copyright © 2016 Daylighting Society. All rights reserved.
//

#ifndef UnmarkPin_h
#define UnmarkPin_h

#import "Coord.h"

@interface UnmarkPin : NSObject

+ (id)unmarkPinAt:(Coord*)c withUsername:(NSString*)username;

@end

#endif /* UnmarkPin_h */
