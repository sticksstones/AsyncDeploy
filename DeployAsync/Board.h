//
//  Board.h
//  DeployAsync
//
//  Created by Vinit Agarwal on 1/23/12.
//  Copyright 2012 Zynga. All rights reserved.
//

#import "CCNode.h"

@class Crystal;
@class Unit;

@interface Board : CCNode {
    NSMutableArray* p1Tokens;
    NSMutableArray* p2Tokens;
    NSMutableArray* p1Crystals;
    NSMutableArray* p2Crystals;
    NSString* boardName;
}

@property (nonatomic, retain) NSString* boardName;

- (NSArray*)getCrystalsForPlayer:(int)playerNum;
- (void)setCrystals:(NSArray*)crystals forPlayer:(int)playerNum;
- (NSArray*)getTokensForPlayer:(int)playerNum;
- (void)setTokens:(NSArray*)tokens forPlayer:(int)playerNum;
- (void)setupBoard:(NSDictionary*)params;
- (void)addCrystal:(Crystal*)crystal;
- (void)addUnit:(Unit*)unit;
- (Unit*)getUnitAtBoardPos:(CGPoint)boardPos;
- (void)setUnit:(Unit*)unit AtBoardPos:(CGPoint)boardPos;
- (void)removeCrystal:(Crystal*)crystal;
- (void)removeUnit:(Unit*)unit;
- (void)LOGGEDmoveUnit:(Unit*)unit toPos:(CGPoint)boardPos;
- (bool)moveUnit:(Unit*)unit toPos:(CGPoint)boardPos;
- (void)LOGGEDunit:(Unit*)unit attacksPos:(CGPoint)boardPos;
- (bool)unit:(Unit*)unit attacksPos:(CGPoint)boardPos;
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
