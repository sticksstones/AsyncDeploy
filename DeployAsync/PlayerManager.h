//
//  PlayerManager.h
//  DeployAsync
//
//  Created by Vinit Agarwal on 1/23/12.
//  Copyright 2012 Zynga. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Hand;
@class Deck;

@interface PlayerManager : NSObject {
    int currentPlayer;
    bool thisPlayersTurn;
    Hand* p1Hand;
    Hand* p2Hand;
    Deck* p1Deck;
    Deck* p2Deck;
    int p1Mana;
    int p2Mana;
    
    int p1ManaMax;
    int p2ManaMax;
}

@property (nonatomic) int currentPlayer;
@property (nonatomic) bool thisPlayersTurn;

@property (nonatomic) int mana;
@property (nonatomic) int manaMax;

@property (readonly) Deck* p1Deck;
@property (readonly) Deck* p2Deck;

@property (readonly) Hand* p1Hand;
@property (readonly) Hand* p2Hand;


@property (readonly) Hand* hand;
@property (readonly) Deck* deck;

+(PlayerManager*)sharedInstance;
-(void)bumpManaMax:(int)amount;
-(void)loseManaMax:(int)amount;
-(bool)hasMana:(int)manaAmount;
-(void)payMana:(int)manaAmount;
-(void)resetMana;
-(void)reset;

@end
