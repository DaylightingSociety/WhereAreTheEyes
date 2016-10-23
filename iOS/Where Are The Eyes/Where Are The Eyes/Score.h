//
//  Score.h
//  Where Are The Eyes
//
//  Created by Milo Trujillo on 7/19/16.
//  Copyright © 2016 Daylighting Society. All rights reserved.
//

#ifndef Score_h
#define Score_h

@interface Score : NSObject

- (Score*)init;
- (BOOL)scoresEnabled;
- (BOOL)scoresWereEnabled;
- (BOOL) usernameChanged:(NSString*) newUsername;
- (void)updateScores:(NSString*)username;
- (int)getVerifications;
- (int)getCameras;

@end

#endif /* Score_h */
