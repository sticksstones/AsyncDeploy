//
//  MatchManager.h
//  DeployAsync
//
//  Created by Vinit Agarwal on 1/24/12.
//  Copyright 2012 Zynga. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GKTurnBasedMatch;

@interface MatchManager : NSObject {
    NSMutableDictionary* currentMatch;
    NSData* cachedMatchData;
}

@property (nonatomic, retain) NSMutableDictionary* currentMatch;
@property (nonatomic, retain) NSData* cachedMatchData;

+(MatchManager*)sharedInstance;
-(NSData*)serialize;
-(void)loadState:(NSData*)matchData;
-(void)setupMatch:(GKTurnBasedMatch*)match;

@end
