//
//  MatchManager.m
//  DeployAsync
//
//  Created by Vinit Agarwal on 1/24/12.
//  Copyright 2012 Zynga. All rights reserved.
//

#import "MatchManager.h"
#import "GameKit/GameKit.h"
#import "PlayerManager.h"
#import "BoardManager.h"
#import "Board.h"
#import "Card.h"
#import "Deck.h"
#import "Hand.h"
#import "Unit.h"
#import "Tile.h"
#import "HelloWorldLayer.h"
#import "RecapLabel.h"

@implementation MatchManager

@synthesize currentMatch, cachedMatchData, moveList, showingRecap, skipRecap;

static MatchManager *sharedInstance = nil;


+(MatchManager*) sharedInstance{
    @synchronized(self){
        if(sharedInstance == nil)
            sharedInstance = [[[self class] alloc] init];
    }
    return sharedInstance;   
}

- (void)reset {
    sharedInstance = nil;
}


- (id)init
{
    self = [super init];
    if (self) {
        currentMatch = [NSMutableDictionary new];
        moveList = [NSMutableArray new];
        skipRecap = NO;
        showingRecap = NO;
    }
    
    return self;
}

- (void)performMove:(NSString*)move {
    NSArray* moveComponents = [move componentsSeparatedByString:@"|"];

    RecapLabel* actionLabel = (RecapLabel*)[[[BoardManager sharedInstance] board] getChildByTag:666];
    
    if(!actionLabel) {
        actionLabel = [[RecapLabel alloc] initWithString:@"NEW UNIT!" fontName:@"Helvetica" fontSize:12.0];
        [actionLabel setColor:ccGREEN];
        
            [[[BoardManager sharedInstance] board] addChild:actionLabel z:0 tag:666];
        actionLabel.position = CGPointMake(200,200);        
    }

    if(skipRecap) {
        [actionLabel setOpacity:0];
    }
    else {
        [actionLabel setOpacity:255];
        [actionLabel setScale:1.0];
    }
    CCSequence* seq = [CCSequence actions:[CCFadeOut actionWithDuration:2.0],[CCCallFuncN actionWithTarget:self selector:@selector(popMove:)],nil];
    CCSequence* seq2 = [CCSequence actions:[CCScaleTo actionWithDuration:2.0 scale:2.5],nil];
    
    if([[moveComponents objectAtIndex:0] isEqualToString:@"move"]) {
        int srcTileTag = [[moveComponents objectAtIndex:1] intValue];
        int destTileTag = [[moveComponents objectAtIndex:2] intValue];
        
        Unit* unit = [[[BoardManager sharedInstance] board] getUnitAtBoardPos:CGPointMake(srcTileTag/10, srcTileTag%10)];
        [[[BoardManager sharedInstance] board] setUnit:unit AtBoardPos:CGPointMake(srcTileTag/10, srcTileTag%10)];
        [[[BoardManager sharedInstance] board] moveUnit:unit toPos:CGPointMake(destTileTag/10, destTileTag%10)];
        Tile* tile = (Tile*)[[[BoardManager sharedInstance] board] getChildByTag:destTileTag];

        if(skipRecap) { // "Fast forward" the unit movement
            [unit stopAllActions];
            [unit setPosition:CGPointMake(tile.position.x, tile.position.y)];
        }
        
        actionLabel.string = @"MOVE";
        actionLabel.color = ccWHITE;
        actionLabel.position = CGPointMake(tile.position.x, tile.position.y);
        
        
    }
    else if([[moveComponents objectAtIndex:0] isEqualToString:@"atk"]) {
        int srcTileTag = [[moveComponents objectAtIndex:1] intValue];
        int destTileTag = [[moveComponents objectAtIndex:2] intValue];
        
        Unit* unit = [[[BoardManager sharedInstance] board] getUnitAtBoardPos:CGPointMake(srcTileTag/10, srcTileTag%10)];
        [[[BoardManager sharedInstance] board] unit:unit attacksPos:CGPointMake(destTileTag/10, destTileTag%10)];

        actionLabel.string = @"ATTACK";
        actionLabel.color = ccWHITE;
        actionLabel.position = CGPointMake(unit.position.x, unit.position.y);

    }
    else if([[moveComponents objectAtIndex:0] isEqualToString:@"play"]) {
        int playerNum = [[moveComponents objectAtIndex:1] intValue];
        NSString* cardName = [moveComponents objectAtIndex:2];
        int destTileTag = [[moveComponents objectAtIndex:3] intValue];
        
        NSString * plistPath = [[NSBundle mainBundle] pathForResource:@"CardData" ofType:@"plist"];
        NSDictionary* cardsData = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        NSMutableDictionary* cardData = [[NSMutableDictionary alloc] initWithDictionary:[cardsData objectForKey:cardName]];
        [cardData setValue:cardName forKey:@"name"];
        
        
        Card* card = [[Card alloc] initWithFile:@"CardBackground.png"];
        [card setParameters:cardData];
        
        [card playCardOnPos:CGPointMake(destTileTag/10, destTileTag%10) playerNum:playerNum];
        
        Tile* tile = (Tile*)[[[BoardManager sharedInstance] board] getChildByTag:destTileTag];
        
        actionLabel.string = [NSString stringWithFormat:@"%@", [cardName uppercaseString]];
        actionLabel.color = ccWHITE;
        actionLabel.position = CGPointMake(tile.position.x, tile.position.y);
    
    }
    
    if(skipRecap) {
        [self popMove:nil];
    }
    else {
        [actionLabel runAction:seq];
        [actionLabel runAction:seq2];        
    }

}

-(void)popMove:(id)sender {
    
    if([moveList count] > 0) {
        NSString* move = [moveList objectAtIndex:0];
        [moveList removeObjectAtIndex:0];
        
        [self performMove:move];

    }
    else {
        [self finishMoveList];
    }
    
}

- (void)finishMoveList {
    moveList = [NSMutableArray new];    
    cachedMatchData = [self serialize];    
    showingRecap = NO;   
    
    RecapLabel* actionLabel = (RecapLabel*)[[[BoardManager sharedInstance] board] getChildByTag:666];
    if(!actionLabel) {
        actionLabel = [[RecapLabel alloc] initWithString:@"NEW UNIT!" fontName:@"Helvetica" fontSize:12.0];        
        [[[BoardManager sharedInstance] board] addChild:actionLabel z:0 tag:666];
    }

    [actionLabel stopAllActions];
    [actionLabel setOpacity:255];
    if([[PlayerManager sharedInstance] thisPlayersTurn]) {
        [actionLabel setString:@"YOUR TURN"];
    }
    
    else {
        [actionLabel setString:@"THEIR TURN"];
    }
    
    [actionLabel setColor:ccWHITE];
    [actionLabel setScale:2.0];
    [actionLabel setPosition:CGPointMake([[[BoardManager sharedInstance] board] contentSize].width/2,[[[BoardManager sharedInstance] board] contentSize].height/2)];
    [actionLabel runAction:[CCSequence actions:[CCFadeOut actionWithDuration:2.0], [CCCallFunc actionWithTarget:actionLabel selector:@selector(kill)],nil]];
    //[[[BoardManager sharedInstance] board] removeChildByTag:666 cleanup:YES];
}

-(void)applyMoveList {
    showingRecap = YES;
    RecapLabel* actionLabel = (RecapLabel*)[[[BoardManager sharedInstance] board] getChildByTag:666];

    if(actionLabel) {
        [actionLabel stopAllActions];
    }
    [self popMove:nil];
    
}

-(void)loadState:(NSData*)matchData {
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:matchData];
    NSDictionary *myDictionary = [[unarchiver decodeObjectForKey:@"Some Key Value"] retain];
    [unarchiver finishDecoding];
    NSArray* p1Deck = [myDictionary objectForKey:@"p1Deck"];
    NSArray* p2Deck = [myDictionary objectForKey:@"p2Deck"];
    NSArray* p1Hand = [myDictionary objectForKey:@"p1Hand"];
    NSArray* p2Hand = [myDictionary objectForKey:@"p2Hand"];
    NSArray* p1Tokens = [myDictionary objectForKey:@"p1Tokens"];
    NSArray* p2Tokens = [myDictionary objectForKey:@"p2Tokens"];
    NSArray* newMoveList = [myDictionary objectForKey:@"moveList"];
    
    moveList = [[NSMutableArray alloc] initWithArray:newMoveList];
    NSString * plistPath = [[NSBundle mainBundle] pathForResource:@"BoardData" ofType:@"plist"];
    NSDictionary* boardsData = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSMutableDictionary* boardData = [[NSMutableDictionary alloc] initWithDictionary:[boardsData objectForKey:[myDictionary valueForKey:@"Board"]]];
    
    [[[BoardManager sharedInstance] board] setupBoard:boardData];
    
    [[[PlayerManager sharedInstance] p1Deck] setDeck:p1Deck];
    [[[PlayerManager sharedInstance] p2Deck] setDeck:p2Deck];
    [[[PlayerManager sharedInstance] p1Hand] setHand:p1Hand];
    [[[PlayerManager sharedInstance] p2Hand] setHand:p2Hand]; 
    [[[BoardManager sharedInstance] board] setTokens:p1Tokens forPlayer:1];
    [[[BoardManager sharedInstance] board] setTokens:p2Tokens forPlayer:-1];        
    
    HelloWorldLayer* layer = (HelloWorldLayer*)[[[CCDirector sharedDirector] runningScene] getChildByTag:0];
    if([layer isKindOfClass:[HelloWorldLayer class]])
        [layer loadTurn];

}

-(void)setupMatch:(GKTurnBasedMatch*)match {
    [match loadMatchDataWithCompletionHandler:^(NSData *matchData, NSError *error) {
        [self loadState:matchData];
        cachedMatchData = matchData;
    }];
}

-(NSData*)serializeMoveList {
    [currentMatch setValue:moveList forKey:@"moveList"];    

    [currentMatch setObject:[[[PlayerManager sharedInstance] p1Deck] serialize] forKey:@"p1Deck"];
    [currentMatch setObject:[[[PlayerManager sharedInstance] p2Deck] serialize] forKey:@"p2Deck"];
    [currentMatch setObject:[[[PlayerManager sharedInstance] p1Hand] serialize] forKey:@"p1Hand"];
    [currentMatch setObject:[[[PlayerManager sharedInstance] p2Hand] serialize] forKey:@"p2Hand"];    
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:currentMatch forKey:@"Some Key Value"];
    [archiver finishEncoding];

    return data;
}

-(NSData*)serialize {
    [currentMatch setObject:[[[PlayerManager sharedInstance] p1Deck] serialize] forKey:@"p1Deck"];
    [currentMatch setObject:[[[PlayerManager sharedInstance] p2Deck] serialize] forKey:@"p2Deck"];
    [currentMatch setObject:[[[PlayerManager sharedInstance] p1Hand] serialize] forKey:@"p1Hand"];
    [currentMatch setObject:[[[PlayerManager sharedInstance] p2Hand] serialize] forKey:@"p2Hand"];
    [currentMatch setObject:[[[BoardManager sharedInstance] board] getTokensForPlayer:1] forKey:@"p1Tokens"];
    [currentMatch setObject:[[[BoardManager sharedInstance] board] getTokensForPlayer:-1] forKey:@"p2Tokens"];
    [currentMatch setValue:[[[BoardManager sharedInstance] board] boardName] forKey:@"Board"];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:currentMatch forKey:@"Some Key Value"];
    [archiver finishEncoding];
    
    return data;
}

- (void)queueMove:(NSString *)move {
    [moveList addObject:move];
}

@end
