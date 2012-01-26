//
//  HelloWorldLayer.h
//  DeployAsync
//
//  Created by Vinit Agarwal on 1/23/12.
//  Copyright Zynga 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "GCTurnBasedMatchHelper.h"
// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <GCTurnBasedMatchHelperDelegate>
{
    CCMenuItem* submitTurn;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
-(void)setupGameScreen;
- (void)setupState:(GKTurnBasedMatch*)match;
-(void)endTurn:(id)sender;
-(void)mainMenu:(id)sender;
- (void)loadTurn;
-(void)reloadGame:(id)sender;
@end
