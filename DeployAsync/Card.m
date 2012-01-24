//
//  Card.m
//  DeployAsync
//
//  Created by Vinit Agarwal on 1/23/12.
//  Copyright 2012 Zynga. All rights reserved.
//

#import "Card.h"
#import "Unit.h"
#import "PlayerManager.h"
#import "BoardManager.h"
#import "Board.h"

#import "Hand.h"

@implementation Card

@synthesize parameters;

- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}

- (void)setParameters:(NSDictionary *)_parameters {
    parameters = [[NSDictionary alloc] initWithDictionary:_parameters];

    int cost = [[parameters valueForKey:@"cost"] intValue];    
    NSString* type = [parameters valueForKey:@"type"];
    NSString* name = [parameters valueForKey:@"name"];
    
    if([type isEqualToString:@"unit"]) {
        int HP = [[parameters valueForKey:@"hp"] intValue];
        int AP = [[parameters valueForKey:@"ap"] intValue];
        
        // Stats label
        CCLabelTTF* statsLabel = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"%d|%d",AP,HP] fontName:@"Helvetica" fontSize:8.0];
        [statsLabel setPosition:CGPointMake(self.contentSize.width - 10, 8)];
        [self addChild:statsLabel];
    }
    
    // Cost label
    CCLabelTTF* costLabel = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"%d",cost] fontName:@"Helvetica" fontSize:8.0];
    [costLabel setPosition:CGPointMake(self.contentSize.width - 8, self.contentSize.height - 8)];
    [self addChild:costLabel];

    // Name label
    CCLabelTTF* nameLabel = [[CCLabelTTF alloc] initWithString:[name uppercaseString] fontName:@"Helvetica" fontSize:10.0];
    [nameLabel setPosition:CGPointMake(self.contentSize.width/2, self.contentSize.height/2)];
    [self addChild:nameLabel];


}

- (bool)playCardOnPos:(CGPoint)boardPos {
    int cost = [[parameters valueForKey:@"cost"] intValue];
    NSString* type = [parameters valueForKey:@"type"];
    
    if([[PlayerManager sharedInstance] hasMana:cost]) {
    if([type isEqualToString:@"unit"]) {    
        int HP = [[parameters valueForKey:@"hp"] intValue];
        int AP = [[parameters valueForKey:@"ap"] intValue];
        int moveRadius = [[parameters valueForKey:@"moveRadius"] intValue];
        int attackRadius = [[parameters valueForKey:@"attackRadius"] intValue];
        
        Unit* unit = [[Unit alloc] initWithFile:@"Unit.png"];
        [unit setHP:HP];
        [unit setMaxHP:HP];
        [unit setAP:AP];
        [unit setMoveRadius:moveRadius];
        [unit setAttackRadius:attackRadius];
        [unit setPlayerNum:[[PlayerManager sharedInstance] currentPlayer]];
        Board* board = [[BoardManager sharedInstance] board];
        [board addUnit:unit];
        [board moveUnit:unit toPos:boardPos];
        
        [[PlayerManager sharedInstance] payMana:cost];
    }
    
    return YES;
    }
    return NO;
    
}

- (void)onEnter
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
	[super onEnter];
}

- (void)onExit
{
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super onExit];
}	

- (CGRect)rectInPixels
{
	CGSize s = [texture_ contentSizeInPixels];
	return CGRectMake(-s.width / 2, -s.height / 2, s.width, s.height);
}

- (CGRect)rect
{
	CGSize s = [texture_ contentSize];
	return CGRectMake(-s.width / 2, -s.height / 2, s.width, s.height);
}

- (BOOL)containsTouchLocation:(UITouch *)touch
{
	CGPoint p = [self convertTouchToNodeSpaceAR:touch];
	CGRect r = [self rectInPixels];
    CGRect test = CGRectMake(1.5*r.origin.x, 1.5*r.origin.y, 1.5*r.size.width, 1.5*r.size.height);
    
	return CGRectContainsPoint(test, p);
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	if (![self containsTouchLocation:touch] ) return NO;

    int cost = [[parameters valueForKey:@"cost"] intValue];
    
    if([[PlayerManager sharedInstance] hasMana:cost]) {

        int playerNum = [[PlayerManager sharedInstance] currentPlayer];
        [[[BoardManager sharedInstance] board] highlightSpawnPoints:playerNum];
        return YES;
    }    
    return NO;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    //    CGPoint touchPoint = [touch locationInView:[touch view]];
    //        touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    //        [self setPosition:CGPointMake(touchPoint.x, touchPoint.y)];
}


- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {	    
    CGPoint boardPos = [[[BoardManager sharedInstance] board] getBoardPosForTouch:touch];
    
    bool cardPlayed = NO;
    if([[[BoardManager sharedInstance] board] isValidSpawnPoint:boardPos]) {
        cardPlayed = [self playCardOnPos:boardPos];
    }
    [[[BoardManager sharedInstance] board] wipeHighlighting];
    
    if(cardPlayed) {
        Hand* hand = [[PlayerManager sharedInstance] hand];    
        [hand removeCard:self];
    }


}




@end