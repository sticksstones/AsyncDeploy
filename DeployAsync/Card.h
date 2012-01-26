//
//  Card.h
//  DeployAsync
//
//  Created by Vinit Agarwal on 1/23/12.
//  Copyright 2012 Zynga. All rights reserved.
//

#import "CCSprite.h"
#import "cocos2d.h"

@interface Card : CCSprite <CCTargetedTouchDelegate> {
    NSDictionary* parameters;
}

@property (nonatomic, retain) NSDictionary* parameters;

- (bool)LOGGEDplayCardOnPos:(CGPoint)boardPos playerNum:(int)playerNum;
- (bool)playCardOnPos:(CGPoint)boardPos playerNum:(int)playerNum;

@end
