//
//  PlayerManager.m
//  DeployAsync
//
//  Created by Vinit Agarwal on 1/23/12.
//  Copyright 2012 Zynga. All rights reserved.
//

#import "PlayerManager.h"
#import "Hand.h"
#import "Deck.h"

#define STARTING_MANA 2
#define STARTING_CARDS 5

@implementation PlayerManager

@synthesize currentPlayer, hand, mana, manaMax;
@synthesize p1Deck,p2Deck,p1Hand,p2Hand;

static PlayerManager *sharedInstance = nil;


+(PlayerManager*) sharedInstance{
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
        p1Hand = [[Hand alloc] init];
        p2Hand = [[Hand alloc] init];
        
        p1Deck = [[Deck alloc] init];
        p2Deck = [[Deck alloc] init];
        
        NSString * plistPath = [[NSBundle mainBundle] pathForResource:@"DeckData" ofType:@"plist"];
        NSDictionary* decksData = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        NSArray* deckData = [[NSArray alloc] initWithArray:[decksData objectForKey:@"HumanDeck"]];
        
        [p1Deck setDeck:deckData];
        [p2Deck setDeck:deckData];
        
        for(int i = 0; i < STARTING_CARDS; ++i) {
            Card* p1Card = [p1Deck drawCard];
            if(p1Card) {
                [p1Hand addCard:p1Card];        
            }
            Card* p2Card = [p2Deck drawCard];
            if(p2Card) {
                [p2Hand addCard:p2Card];        
            }
            
        }
        
        p1ManaMax = p2ManaMax = STARTING_MANA;
    }
    
    return self;
}

- (Hand*)hand {
    return currentPlayer == 1 ? p1Hand : p2Hand;
}

- (Deck*)deck {
    return currentPlayer == 1 ? p1Deck : p2Deck;
}

- (int)mana {
    return currentPlayer == 1 ? p1Mana : p2Mana;
}

- (void)setMana:(int)_mana {
    currentPlayer == 1 ? (p1Mana = _mana) : (p2Mana = _mana);
    [[[PlayerManager sharedInstance] hand] updateManaLabel];
}

- (void)setManaMax:(int)_manaMax {
    currentPlayer == 1 ? (p1ManaMax = _manaMax) : (p2ManaMax = _manaMax);
    if([self mana] > [self manaMax]) [self setMana:[self manaMax]];
}

- (int)manaMax {
    return currentPlayer == 1 ? p1ManaMax : p2ManaMax;
}

-(void)bumpManaMax:(int)amount {
    [self setManaMax:[self manaMax]+amount];
}
-(void)loseManaMax:(int)amount {
    [self setManaMax:[self manaMax]-amount];
}

-(bool)hasMana:(int)manaAmount {
    return [self mana] >= manaAmount;
}
-(void)payMana:(int)manaAmount {
    [self setMana:[self mana]-manaAmount];
}

-(void)resetMana {
    [self setMana:[self manaMax]];
}

@end
