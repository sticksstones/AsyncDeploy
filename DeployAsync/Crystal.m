//
//  Crystal.m
//  DeployAsync
//
//  Created by Vinit Agarwal on 1/26/12.
//  Copyright 2012 Zynga. All rights reserved.
//

#import "Crystal.h"

#define kHealthLabel 100

@implementation Crystal

@synthesize HP, maxHP, playerNum, boardPos;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        CCLabelTTF* healthLabel = [CCLabelTTF labelWithString:@"0" fontName:@"Helvetica" fontSize:12.0];
        [healthLabel setColor:ccMAGENTA];
        [self addChild:healthLabel z:1 tag:kHealthLabel];
    }
    
    return self;
}

- (void)setHP:(int)_HP {
    HP = _HP;
    CCLabelTTF* hpLabel = (CCLabelTTF*)[self getChildByTag:kHealthLabel];
    [hpLabel setString:[NSString stringWithFormat:@"%d",HP]];
}

- (void)damage:(int)amount {
    self.HP -= amount;
}

- (void)setPlayerNum:(int)_playerNum {
    playerNum = _playerNum;
    self.color = playerNum == 1 ? ccBLUE : ccRED;
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
    
    return YES;
    
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {

}


- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {	
    
}

- (void)setupCrystal:(NSDictionary*)state {    
    [self setPlayerNum:[[state valueForKey:@"owner"] intValue]];
    [self setHP:[[state valueForKey:@"HP"] intValue]];
    
    int boardX = [[state valueForKey:@"BOARD_X"] intValue];
    int boardY = [[state valueForKey:@"BOARD_Y"] intValue];
    
    [self setBoardPos:CGPointMake(boardX, boardY)];
}

- (NSDictionary*)serialize {
    NSMutableDictionary* serialized = [NSMutableDictionary new];
    [serialized setValue:[NSNumber numberWithInt:HP] forKey:@"HP"];
    [serialized setValue:[NSNumber numberWithInt:boardPos.x] forKey:@"BOARD_X"];
    [serialized setValue:[NSNumber numberWithInt:boardPos.y] forKey:@"BOARD_Y"]; 
    [serialized setValue:[NSNumber numberWithInt:[self playerNum]] forKey:@"owner"]; 
    
    return serialized;    
}


@end
