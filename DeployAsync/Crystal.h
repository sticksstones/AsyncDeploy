//
//  Crystal.h
//  DeployAsync
//
//  Created by Vinit Agarwal on 1/26/12.
//  Copyright 2012 Zynga. All rights reserved.
//

#import "CCSprite.h"
#import "cocos2d.h"

@interface Crystal : CCSprite <CCTargetedTouchDelegate> {
    int maxHP;
    int HP;
    int playerNum;
    CGPoint boardPos;
}

@property (nonatomic) int maxHP;
@property (nonatomic) int HP;
@property (nonatomic) int playerNum;
@property (nonatomic) CGPoint boardPos;

- (void)damage:(int)amount;
- (NSDictionary*)serialize;
- (void)setupCrystal:(NSDictionary*)state;

@end
