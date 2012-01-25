//
//  MainMenuLayer.m
//  DeployAsync
//
//  Created by Vinit Agarwal on 1/24/12.
//  Copyright 2012 Zynga. All rights reserved.
//

#import "MainMenuLayer.h"
#import "AppDelegate.h"
#import "RootViewController.h"
#import "GCTurnBasedMatchHelper.h"
#import "HelloWorldLayer.h"

@implementation MainMenuLayer


+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MainMenuLayer *layer = [MainMenuLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer z:0 tag:0];
	// return the scene
	return scene;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        CCMenuItemLabel* menuItem = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"START" fontName:@"Helvetica" fontSize:16.0] target:self selector:@selector(matchmake:)];
        CCMenu* menu = [CCMenu menuWithItems:menuItem, nil];
        [self addChild:menu];
        menu.position = CGPointMake(50, 50);
    }
    
    return self;
}

-(void)matchmake:(id)sender {
    [[CCDirector sharedDirector] replaceScene:[HelloWorldLayer scene]];        
    
    UIViewController* tempVC=[[UIViewController alloc] init];    
    [[[CCDirector sharedDirector] openGLView] addSubview:tempVC.view];
    [[GCTurnBasedMatchHelper sharedInstance] 
     findMatchWithMinPlayers:2 maxPlayers:2 viewController:tempVC];
}



@end
