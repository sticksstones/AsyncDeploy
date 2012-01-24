//
//  Hand.h
//  DeployAsync
//
//  Created by Vinit Agarwal on 1/23/12.
//  Copyright 2012 Zynga. All rights reserved.
//

#import "CCNode.h"
#import "Card.h"
#import "cocos2d.h"

@interface Hand : CCNode {
    NSMutableArray* cards;
}

@property (nonatomic, retain) NSMutableArray* cards;

- (void)readjustCards;
- (void)addCard:(Card*)card;
- (void)removeCard:(Card*)card;
- (void)updateManaLabel;

@end
