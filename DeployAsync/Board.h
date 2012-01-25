//
//  Board.h
//  DeployAsync
//
//  Created by Vinit Agarwal on 1/23/12.
//  Copyright 2012 Zynga. All rights reserved.
//

#import "CCNode.h"

@class Unit;

@interface Board : CCNode {
    NSMutableArray* p1Tokens;
    NSMutableArray* p2Tokens;
    NSString* boardName;
}

@property (nonatomic, retain) NSString* boardName;

- (NSArray*)getTokensForPlayer:(int)playerNum;
- (void)setTokens:(NSArray*)tokens forPlayer:(int)playerNum;
- (void)setupBoard:(NSDictionary*)params;
- (void)addUnit:(Unit*)unit;
- (void)removeUnit:(Unit*)unit;
- (void)moveUnit:(Unit*)unit toPos:(CGPoint)boardPos;
- (void)unit:(Unit*)unit attacksPos:(CGPoint)boardPos;
- (void)highlightSpawnPoints:(int)playerNum;
- (void)highlightMovePoints:(Unit*)unit;
- (void)highlightAttackPoints:(Unit*)unit;
- (void)resetTiles;
- (void)wipeHighlighting;
- (void)startTurn:(int)playerNum;
- (void)endTurn;
- (CGPoint)getBoardPosForTouch:(UITouch*)touch;
- (bool)isValidSpawnPoint:(CGPoint)boardPos;
@end
