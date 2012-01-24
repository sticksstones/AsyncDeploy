//
//  HelloWorldLayer.m
//  DeployAsync
//
//  Created by Vinit Agarwal on 1/23/12.
//  Copyright Zynga 2012. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import "BoardManager.h"
#import "PlayerManager.h"
#import "Board.h"
#import "Unit.h"
#import "Card.h"
#import "Hand.h"
#import "Deck.h"

// HelloWorldLayer implementation
@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer z:0 tag:0];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		
		// create and initialize a Label

		// ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
        
        // Create the board
        Board* board = [[Board alloc] init];        
        [[BoardManager sharedInstance] setBoard:board];
        
        NSString * plistPath = [[NSBundle mainBundle] pathForResource:@"BoardData" ofType:@"plist"];
        NSDictionary* boardsData = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        NSMutableDictionary* boardData = [[NSMutableDictionary alloc] initWithDictionary:[boardsData objectForKey:@"Board1"]];

        
        [board setupBoard:boardData];
        
        board.position = CGPointMake(50 + size.width/2 - board.contentSize.width/2, size.height/2 - board.contentSize.height/2);
        [self addChild:board];
        
        [board startTurn:1];
        
        // Setup End Turn Button
        CCMenuItem* menuItem = [CCMenuItemImage itemFromNormalImage:@"End Turn.png" selectedImage:nil target:self selector:@selector(endTurn:)];
        CCMenu* menu = [CCMenu menuWithItems:menuItem, nil];
        menu.position = CGPointMake(60, 25);
        [self addChild:menu];
	}
	return self;
}

-(void)endTurn:(id)sender {

    // Update the board
    [[[BoardManager sharedInstance] board] endTurn];

    // Replace hand with current player's hand
    Hand* hand = [[PlayerManager sharedInstance] hand];
    [self removeChildByTag:100 cleanup:NO];
    [self addChild:hand z:0 tag:100];

    // Replace deck with current player's deck
    Deck* deck = [[PlayerManager sharedInstance] deck];
    [self removeChildByTag:200 cleanup:NO];
    [self addChild:deck z:0 tag:200];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
