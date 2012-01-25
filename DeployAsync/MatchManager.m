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
#import "Deck.h"
#import "Hand.h"
#import "HelloWorldLayer.h"

@implementation MatchManager

@synthesize currentMatch, cachedMatchData;

static MatchManager *sharedInstance = nil;


+(MatchManager*) sharedInstance{
    @synchronized(self){
        if(sharedInstance == nil)
            sharedInstance = [[[self class] alloc] init];
    }
    return sharedInstance;   
}


- (id)init
{
    self = [super init];
    if (self) {
        currentMatch = [NSMutableDictionary new];
    }
    
    return self;
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
    [layer loadTurn];

}

-(void)setupMatch:(GKTurnBasedMatch*)match {
    [match loadMatchDataWithCompletionHandler:^(NSData *matchData, NSError *error) {
        [self loadState:matchData];
        cachedMatchData = matchData;
    }];
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

    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSDictionary *myDictionary = [[unarchiver decodeObjectForKey:@"Some Key Value"] retain];
    [unarchiver finishDecoding];

    
    return data;
    
    //    NSData *data = [[NSMutableData alloc] initWithContentsOfFile:[self dataFilePath]];
    //    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    //    NSDictionary *myDictionary = [[unarchiver decodeObjectForKey:@"Some Key Value"] retain];
    //    [unarchiver finishDecoding];
    //    [unarchiver release];
    //    [data release];
}

@end
