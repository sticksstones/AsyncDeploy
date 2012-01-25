//
//  MainMenuLayer.h
//  DeployAsync
//
//  Created by Vinit Agarwal on 1/24/12.
//  Copyright 2012 Zynga. All rights reserved.
//

#import "CCLayer.h"
#import "cocos2d.h"
#import "GCTurnBasedMatchHelper.h"

@interface MainMenuLayer : CCLayer

+(CCScene *) scene;
-(void)matchmake:(id)sender;

@end
