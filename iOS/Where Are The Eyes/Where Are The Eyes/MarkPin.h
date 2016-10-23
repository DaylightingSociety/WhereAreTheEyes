//
//  MarkPin.h
//  Where Are The Eyes
//
//  Created by Milo Trujillo on 6/2/16.
//  Copyright © 2016 Daylighting Society. All rights reserved.
//

#ifndef MarkPin_h
#define MarkPin_h

#import "Coord.h"

@interface MarkPin : NSObject

+ (id)markPinAt:(Coord*)c withUsername:(NSString*)username;

@end

#endif /* MarkPin_h */