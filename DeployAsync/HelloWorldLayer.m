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
#import "MatchManager.h"
#import "MainMenuLayer.h"

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
        [GCTurnBasedMatchHelper sharedInstance].delegate = self;        
		// ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
        
        // Create the board
        Board* board = [[Board alloc] init];        
        [[BoardManager sharedInstance] setBoard:board];
        
        NSString * plistPath = [[NSBundle mainBundle] pathForResource:@"BoardData" ofType:@"plist"];
        NSDictionary* boardsData = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        NSMutableDictionary* boardData = [[NSMutableDictionary alloc] initWithDictionary:[boardsData objectForKey:@"Board1"]];

        [board setupBoard:boardData];
        [board setBoardName:@"Board1"];
        [[[PlayerManager sharedInstance] p1Deck] shuffle];
        [[[PlayerManager sharedInstance] p2Deck] shuffle];
        
        board.position = CGPointMake(50 + size.width/2 - board.contentSize.width/2, size.height/2 - board.contentSize.height/2);
        [self addChild:board];
                
        // Setup End Turn Button
        CCMenuItem* menuItem = [CCMenuItemImage itemFromNormalImage:@"End Turn.png" selectedImage:nil disabledImage:@"End Turn Disabled.png" target:self selector:@selector(endTurn:)];
        CCMenuItem* menuItem2 = [CCMenuItemImage itemFromNormalImage:@"Reload.png" selectedImage:nil disabledImage:nil target:self selector:@selector(reloadGame:)];
        submitTurn = menuItem;
        menuItem2.position = CGPointMake(50,0);
        CCMenu* menu = [CCMenu menuWithItems:menuItem,menuItem2, nil];
        menu.position = CGPointMake(40, 25);
        [self addChild:menu];
        
        menuItem = [CCMenuItemImage itemFromNormalImage:@"Main Menu.png" selectedImage:nil disabledImage:nil target:self selector:@selector(mainMenu:)];
        menuItem2 = [CCMenuItemImage itemFromNormalImage:@"End Game.png" selectedImage:nil disabledImage:nil target:self selector:@selector(endGame:)];
        menuItem2.position = CGPointMake(0, -50);
        menu = [CCMenu menuWithItems:menuItem, menuItem2, nil];
        menu.position = CGPointMake(60, 460);
        [self addChild:menu];

	}
	return self;
}

-(void)mainMenu:(id)sender {
    [[CCDirector sharedDirector] replaceScene:[MainMenuLayer scene]];
}
-(void)endTurn:(id)sender {

    // Update the board
    [[[BoardManager sharedInstance] board] endTurn];    

    submitTurn.isEnabled = NO;

}

-(void)endGame:(id)sender {
    
     GKTurnBasedMatch *currentMatch = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
     for (GKTurnBasedParticipant *part in currentMatch.participants) {
     part.matchOutcome = GKTurnBasedMatchOutcomeTied;
     }
     [currentMatch endMatchInTurnWithMatchData:[[MatchManager sharedInstance] serialize] completionHandler:^(NSError *error) {
     if (error) {
     NSLog(@"%@", error);
     }
     }];
     [self mainMenu:nil];

}

-(void)reloadGame:(id)sender {
    [self setupState:[[GCTurnBasedMatchHelper sharedInstance] currentMatch]];
    //[[MatchManager sharedInstance] loadState:[[MatchManager sharedInstance] cachedMatchData]];
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

- (void)loadTurn {
    [[[BoardManager sharedInstance] board] startTurn:[[PlayerManager sharedInstance] currentPlayer]];
    
    // Replace hand with current player's hand
    Hand* hand = [[PlayerManager sharedInstance] hand];
    [self removeChildByTag:100 cleanup:NO];
    [self addChild:hand z:0 tag:100];
    [hand readjustCards];
    
    // Replace deck with current player's deck
    Deck* deck = [[PlayerManager sharedInstance] deck];
    [deck updateDeckCountText];
    [self removeChildByTag:200 cleanup:NO];
    [self addChild:deck z:0 tag:200];    
}

- (void)setupState:(GKTurnBasedMatch*)match {    
    // Setup the match
    [[MatchManager sharedInstance] setupMatch:match];    
}

- (void)layoutMatch:(GKTurnBasedMatch *)match {
    NSUInteger currentIndex = [match.participants indexOfObject:match.currentParticipant];    
    
    // Assign player nums
    int playerNum = currentIndex == 0 ? -1 : 1;

    [[PlayerManager sharedInstance] setCurrentPlayer:playerNum];        
    [self setupState:match];
    
    submitTurn.isEnabled = NO;

}
- (void)takeTurn:(GKTurnBasedMatch *)match {
    NSUInteger currentIndex = [match.participants indexOfObject:match.currentParticipant];    
    
    // Assign player nums
    int playerNum = currentIndex == 0 ? 1 : -1;    
    [[PlayerManager sharedInstance] setCurrentPlayer:playerNum];        

    [self setupState:match];
    
    submitTurn.isEnabled = YES;
}

- (void)recieveEndGame:(GKTurnBasedMatch *)match {
    
}
- (void)sendNotice:(NSString *)notice forMatch:(GKTurnBasedMatch *)match {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert" message:notice delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
}

-(void)enterNewGame:(GKTurnBasedMatch *)match {
    NSData* initialState = [[MatchManager sharedInstance] serialize];
    [[MatchManager sharedInstance] setCachedMatchData:initialState];
    //[self layoutMatch:match];
    [[PlayerManager sharedInstance] setCurrentPlayer:1];
    [self loadTurn];
    submitTurn.isEnabled = YES;

}



@end
