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
#import "RecapLabel.h"

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
        [GCTurnBasedMatchHelper sharedInstance].delegate = self;  
        //[self registerWithTouchDispatcher];
        self.isTouchEnabled = YES;
	}
	return self;
}

- (void)reset {
    [self removeAllChildrenWithCleanup:YES];
    [[BoardManager sharedInstance] reset];
    [[PlayerManager sharedInstance] reset];
    [[MatchManager sharedInstance] reset];
    [self setupGameScreen];    
}

-(void)setupGameScreen {
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
    [board setBoardName:@"Board1"];
    [[[PlayerManager sharedInstance] p1Deck] shuffle];
    [[[PlayerManager sharedInstance] p2Deck] shuffle];
    
    board.position = CGPointMake(50 + size.width/2 - board.contentSize.width/2, size.height/2 - board.contentSize.height/2);
    [self addChild:board];
    
    // Setup End Turn Button
    CCMenuItem* menuItem = [CCMenuItemImage itemFromNormalImage:@"End Turn.png" selectedImage:nil disabledImage:@"End Turn Disabled.png" target:self selector:@selector(endTurn:)];
    CCMenuItem* menuItem2 = [CCMenuItemImage itemFromNormalImage:@"Reload.png" selectedImage:nil disabledImage:@"Disabled Reload.png" target:self selector:@selector(reloadGame:)];
    submitTurn = menuItem;
    reloadButton = menuItem2;
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

-(void)mainMenu:(id)sender {
    [self reset];
    UIViewController* tempVC=[[UIViewController alloc] init];    
    [[[CCDirector sharedDirector] openGLView] addSubview:tempVC.view];
    [[GCTurnBasedMatchHelper sharedInstance] 
     findMatchWithMinPlayers:2 maxPlayers:2 viewController:tempVC];
    
    //[[CCDirector sharedDirector] replaceScene:[MainMenuLayer scene]];
}
-(void)endTurn:(id)sender {
    
    
    // Update the board
    [[[BoardManager sharedInstance] board] endTurn];    
    
    [[PlayerManager sharedInstance] setMana:0];
    submitTurn.isEnabled = NO;
    reloadButton.isEnabled = NO;
    
}

-(void)endGame:(id)sender {
    
    GKTurnBasedMatch *currentMatch = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
    for (GKTurnBasedParticipant *part in currentMatch.participants) {
        if([part.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
            part.matchOutcome = GKTurnBasedMatchOutcomeQuit;
        }
        else {
            part.matchOutcome = GKTurnBasedMatchOutcomeWon;            
        }
    }
    [currentMatch endMatchInTurnWithMatchData:[[MatchManager sharedInstance] serialize] completionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        }
    }];
    [self mainMenu:nil];
    
}

-(void)reloadGame:(id)sender {
    //[self reset];
    [[MatchManager sharedInstance] setSkipRecap:NO];
    [self setupState:[[GCTurnBasedMatchHelper sharedInstance] currentMatch]];
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
    
    [[MatchManager sharedInstance] applyMoveList];
}

- (void)setupState:(GKTurnBasedMatch*)match {    
    // Setup the match
    [[MatchManager sharedInstance] setupMatch:match];
}

- (void)layoutMatch:(GKTurnBasedMatch *)match {
    [self reset];
    firstTurn = NO;
    [[PlayerManager sharedInstance] setThisPlayersTurn:NO];
    NSUInteger currentIndex = [match.participants indexOfObject:match.currentParticipant];    
    
    // Assign player nums
    int playerNum = currentIndex == 0 ? -1 : 1;
    
    [[PlayerManager sharedInstance] setCurrentPlayer:playerNum];        
    [self setupState:match];
    
    submitTurn.isEnabled = NO;
    
    
}
- (void)takeTurn:(GKTurnBasedMatch *)match {
    [self reset];
    firstTurn = NO;
    
    [[PlayerManager sharedInstance] setThisPlayersTurn:YES];
    NSUInteger currentIndex = [match.participants indexOfObject:match.currentParticipant];    
    
    // Assign player nums
    int playerNum = currentIndex == 0 ? 1 : -1;    
    
    
    [[PlayerManager sharedInstance] setCurrentPlayer:playerNum];        
    
    [self setupState:match];
    
    submitTurn.isEnabled = YES;
}

- (void)recieveEndGame:(GKTurnBasedMatch *)match {
    NSLog(@"Received end game!"); 
    [self layoutMatch:match];
}
- (void)sendNotice:(NSString *)notice forMatch:(GKTurnBasedMatch *)match {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Alert" message:notice delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
}

-(void)enterNewGame:(GKTurnBasedMatch *)match {
    [self reset];
    [[PlayerManager sharedInstance] setThisPlayersTurn:YES];
    
    [[PlayerManager sharedInstance] setCurrentPlayer:1];
    [self loadTurn];
    
    NSData* initialState = [[MatchManager sharedInstance] serialize];
    [[MatchManager sharedInstance] setCachedMatchData:initialState];

    [self removeAllChildrenWithCleanup:YES];
    
    GKTurnBasedMatch *currentMatch = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
    
    NSUInteger currentIndex = [currentMatch.participants indexOfObject:currentMatch.currentParticipant];
    GKTurnBasedParticipant *nextParticipant;
    
    NSUInteger nextIndex = currentIndex;
    nextParticipant = [currentMatch.participants objectAtIndex:nextIndex];
    
    [currentMatch endTurnWithNextParticipant:nextParticipant matchData:initialState completionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
        }
    }];
    NSLog(@"Send Turn, %@, %@", initialState, nextParticipant);

    
    CCMenuItemImage* menuItem = [CCMenuItemImage itemFromNormalImage:@"Main Menu.png" selectedImage:nil disabledImage:nil target:self selector:@selector(mainMenu:)];
    CCMenu* menu = [CCMenu menuWithItems:menuItem, nil];
    menu.position = CGPointMake(60, 460);
    [self addChild:menu];
    
    RecapLabel* recapLabel = [[RecapLabel alloc] initWithString:@"LOADING..." fontName:@"Helvetica" fontSize:32.0];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    recapLabel.position = CGPointMake(winSize.width/2, winSize.height/2);
    [self addChild:recapLabel];    
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if([[MatchManager sharedInstance] showingRecap]) {
        //[self reset];
        [[MatchManager sharedInstance] setSkipRecap:YES];
        [self setupState:[[GCTurnBasedMatchHelper sharedInstance] currentMatch]];
        submitTurn.isEnabled = [[PlayerManager sharedInstance] thisPlayersTurn];
    }
    
}



@end
