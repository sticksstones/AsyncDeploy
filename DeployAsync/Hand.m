//
//  Hand.m
//  DeployAsync
//
//  Created by Vinit Agarwal on 1/23/12.
//  Copyright 2012 Zynga. All rights reserved.
//

#import "Hand.h"
#import "Card.h"
#import "PlayerManager.h"

#define SPACING 12
#define kManaLabel 100

@implementation Hand

@synthesize cards;

- (id)init
{
    self = [super init];
    if (self) {
        cards = [NSMutableArray new];
        self.position = CGPointMake(30, 40);
        CCLabelTTF* manaLabel = [[CCLabelTTF alloc] initWithString:@"0" fontName:@"Helvetica" fontSize:12.0];
        manaLabel.color = ccMAGENTA;
        [self addChild:manaLabel z:0 tag:kManaLabel];
    }
    
    return self;
}

- (void)readjustCards {
    for(int y = 0; y < [cards count]; ++y) {
        Card* card = [cards objectAtIndex:y];
        
        CGPoint newCardPosition = CGPointMake(self.position.x, self.position.y + y*(card.contentSize.height + SPACING));
        CCActionEase* moveToTile = [CCActionEase actionWithAction:[CCMoveTo actionWithDuration:1.0 position:newCardPosition]];
        [card runAction:moveToTile];
    }
}
- (void)addCard:(Card*)card {
    [cards addObject:card];    
    [card setPosition:CGPointMake(self.position.x, 500)];
    [self addChild:card];
    [self readjustCards];
}
- (void)removeCard:(Card*)card {
    [cards removeObject:card];
    [self removeChild:card cleanup:YES];
    [self readjustCards];
}

- (void)updateManaLabel {
    int mana = [[PlayerManager sharedInstance] mana];
    CCLabelTTF* manaLabel = (CCLabelTTF*)[self getChildByTag:kManaLabel];
    [manaLabel setString:[NSString stringWithFormat:@"MANA: %d",mana]];
    manaLabel.position = CGPointMake(self.position.x + 15, 400);
}


@end
