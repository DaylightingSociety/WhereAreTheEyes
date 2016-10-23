//
//  Coord.h
//  Where Are The Eyes
//
//  Created by Milo Trujillo on 5/31/16.
//  Copyright © 2016 Daylighting Society. All rights reserved.
//

#ifndef Coord_h
#define Coord_h

@interface Coord : NSObject

@property float latitude;
@property float longitude;
@property int verifications;

- (Coord*)initLatitude:(float)lat longitude:(float)lon confirmations:(int)verifications;

@end

#endif /* Coord_h */
