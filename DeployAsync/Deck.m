//
//  Deck.m
//  DeployAsync
//
//  Created by Vinit Agarwal on 1/23/12.
//  Copyright 2012 Zynga. All rights reserved.
//

#import "Deck.h"
#import "Card.h"

#define kCardCountLabel 100

@implementation Deck

@synthesize cards;

- (id)init
{
    self = [super init];
    if (self) {
        cards = [NSMutableArray new];
        CCLabelTTF* cardCount = [[CCLabelTTF alloc] initWithString:@"0" fontName:@"Helvetica" fontSize:12.0];
        [self addChild:cardCount z:0 tag:kCardCountLabel];        
        self.position = CGPointMake(50, 430);
        
        [self shuffle];
    }
    
    return self;
}

- (void)setDeck:(NSArray*)deck {
    [cards removeAllObjects];
    for(NSString* card in deck) {
        [cards addObject:card];
    }    
}

- (void)updateDeckCountText {
    CCLabelTTF* cardCount = (CCLabelTTF*)[self getChildByTag:kCardCountLabel];
    [cardCount setString:[NSString stringWithFormat:@"DECK COUNT: %d",[cards count]]];
}

- (Card*)drawCard {
    if([cards count] > 0) {
        NSString* card = [cards objectAtIndex:0];
        [cards removeObjectAtIndex:0];
        
        NSString * plistPath = [[NSBundle mainBundle] pathForResource:@"CardData" ofType:@"plist"];
        NSDictionary* cardsData = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        NSMutableDictionary* cardData = [[NSMutableDictionary alloc] initWithDictionary:[cardsData objectForKey:card]];
        [cardData setValue:card forKey:@"name"];
        
        
        Card* cardObj = [[Card alloc] initWithFile:@"CardBackground.png"];
        
        [cardObj setParameters:cardData];
        [self updateDeckCountText];
        return cardObj;
    }
    return nil;
}

- (void)addCard:(NSString*)card {
    [cards addObject:card];
    [self updateDeckCountText];    
}

- (void)shuffle {
    if([cards count] > 0) {
    NSMutableArray* newCardOrder = [NSMutableArray new];
    do {
        int r = arc4random() % [cards count];
        NSString* card = [cards objectAtIndex:r];
        [newCardOrder addObject:[[NSMutableString alloc] initWithString:card]];
        [cards removeObjectAtIndex:r];    
    } while ([cards count] > 0);
    
    cards = newCardOrder;
    }
}

- (NSArray*)serialize {
    return [[NSArray alloc] initWithArray:cards];
}




@end
