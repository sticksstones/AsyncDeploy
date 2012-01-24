//
//  HelloWorldLayer.h
//  DeployAsync
//
//  Created by Vinit Agarwal on 1/23/12.
//  Copyright Zynga 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer
{
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
-(void)endTurn:(id)sender;

@end
