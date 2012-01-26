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
    NSMutableArray* moveList;
    bool showingRecap;
    bool skipRecap;
}

@property (nonatomic, retain) NSMutableArray* moveList;
@property (nonatomic, retain) NSMutableDictionary* currentMatch;
@property (nonatomic, retain) NSData* cachedMatchData;
@property (nonatomic) bool showingRecap;
@property (nonatomic) bool skipRecap;

+(MatchManager*)sharedInstance;
-(NSData*)serialize;
-(void)loadState:(NSData*)matchData;
-(void)setupMatch:(GKTurnBasedMatch*)match;
-(void)queueMove:(NSString*)move;
-(void)applyMoveList;
-(void)popMove:(id)sender;
- (void)finishMoveList;
-(NSData*)serializeMoveList;
-(void)reset;

@end
