//
//  Tile.h
//  DeployAsync
//
//  Created by Vinit Agarwal on 1/23/12.
//  Copyright 2012 Zynga. All rights reserved.
//

#import "CCSprite.h"
#import "cocos2d.h"

@class Unit;
@class Crystal;

@interface Tile : CCSprite <CCTargetedTouchDelegate> {
    bool highlighted;
    bool occupied;
    bool attackable;
    Unit* occupyingUnit;
    Crystal* crystal;
    CGPoint boardPos; 
    int manaValue;
}

@property (nonatomic) bool highlighted;
@property (nonatomic) bool attackable;
@property (nonatomic) bool occupied;
@property (nonatomic) CGPoint boardPos;
@property (nonatomic, retain) Unit* occupyingUnit;
@property (nonatomic, retain) Crystal* crystal;
@property (nonatomic) int manaValue;

- (void)reset;
- (BOOL)containsTouchLocation:(UITouch *)touch;
- (void)checkAttackable:(Unit*)unit;

@end
