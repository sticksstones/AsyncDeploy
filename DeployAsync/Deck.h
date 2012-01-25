//
//  Deck.h
//  DeployAsync
//
//  Created by Vinit Agarwal on 1/23/12.
//  Copyright 2012 Zynga. All rights reserved.
//

#import "CCNode.h"

@class Card;

@interface Deck : CCNode {
    NSMutableArray* cards;
}

@property (nonatomic, retain) NSMutableArray* cards;

- (void)setDeck:(NSArray*)deck;
- (Card*)drawCard;
- (void)addCard:(NSString*)card;
- (void)shuffle;
- (NSArray*)serialize;
- (void)updateDeckCountText;

@end
