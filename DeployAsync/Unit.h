//
//  Unit.h
//  DeployAsync
//
//  Created by Vinit Agarwal on 1/23/12.
//  Copyright 2012 Zynga. All rights reserved.
//

#import "CCSprite.h"
#import "cocos2d.h"

@interface Unit : CCSprite <CCTargetedTouchDelegate> {
    NSString* cardName;
    
    int moveRadius;
    int origMoveRadius;
    
    int attackRadius;
    int origAttackRadius;
        
    int HP;
    int maxHP;
    
    int AP;
    int origAP;
    
    CGPoint boardPos;
    bool highlighted;
    int playerNum;
    
    bool moveUsed;
    bool actionUsed;
}

@property (nonatomic) bool highlighted;
@property (nonatomic) int moveRadius;
@property (nonatomic) int attackRadius;
@property (nonatomic) CGPoint boardPos;
@property (nonatomic) int playerNum;
@property (nonatomic, retain) NSString* cardName;

@property (nonatomic) int HP;
@property (nonatomic) int maxHP;

@property (nonatomic) int AP;

@property (nonatomic) bool moveUsed;
@property (nonatomic) bool actionUsed;

- (void)updateStatsLabel;
- (void)damage:(int)amount;
- (void)setupFromCardParams:(NSDictionary*)params;
- (void)setupUnit:(NSDictionary*)state;
- (NSDictionary*)serialize;

@end
