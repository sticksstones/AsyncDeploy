//
//  Tile.m
//  DeployAsync
//
//  Created by Vinit Agarwal on 1/23/12.
//  Copyright 2012 Zynga. All rights reserved.
//

#import "Tile.h"
#import "BoardManager.h"
#import "Board.h"
#import "Unit.h"

#define kManaLabel 100

@implementation Tile

@synthesize highlighted, occupied, boardPos, occupyingUnit, attackable,manaValue;

- (id)init
{
    self = [super init];
    if (self) {
        occupied = NO;
        highlighted = NO;
        CCLabelTTF* manaLabel = [[CCLabelTTF alloc] initWithString:@"" fontName:@"Helvetica" fontSize:12.0];
        [manaLabel setColor:ccMAGENTA];
        [self addChild:manaLabel z:1 tag:kManaLabel];
        [manaLabel setVisible:NO];
        // Initialization code here.
    }
    
    return self;
}

- (void)setManaValue:(int)_manaValue {
    manaValue = _manaValue;
    if(manaValue > 0) {
        CCLabelTTF* manaLabel = (CCLabelTTF*)[self getChildByTag:kManaLabel];
        
        NSString* manaText = @"";
        for(int x = 0; x < manaValue; ++x) {
            manaText = [manaText stringByAppendingString:@"X"];
        }
        
        [manaLabel setString:manaText];
        [manaLabel setVisible:YES];
        [manaLabel setPosition:CGPointMake(self.contentSize.width/2, self.contentSize.height/2)];
    }
}

- (void)setAttackable:(_Bool)_attackable {
    attackable = _attackable;

    ccColor3B origColor = ccc3(self.color.r, self.color.g, self.color.b);
    self.color = _attackable ? ccRED : origColor;
}

- (void)reset {
    [self setOccupied:NO];
    [self setAttackable:NO];
    [self setOccupyingUnit:nil];
    [self setHighlighted:NO];
}


- (void)setHighlighted:(_Bool)_highlighted {
    highlighted = _highlighted;
    self.color = highlighted ? ccGREEN : ccWHITE;
}

- (void)setOccupied:(_Bool)_occupied {
    occupied = _occupied;
    occupyingUnit = occupied ? occupyingUnit : nil;
}

- (void)setOccupyingUnit:(Unit *)_occupyingUnit {
    occupyingUnit = _occupyingUnit;
    occupied = occupyingUnit ? YES : NO;
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

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {	
    CGPoint touchPoint = [touch locationInView:[touch view]];
    
    Unit* unit = [[BoardManager sharedInstance] selectedUnit];
    
    if(unit && !unit.moveUsed && self.highlighted && !self.attackable) {
        Board* board = [[BoardManager sharedInstance] board];
        [unit setMoveUsed:YES];        
        [board moveUnit:unit toPos:self.boardPos];
    }
    else if(unit && !unit.actionUsed && self.attackable) {
        Board* board = [[BoardManager sharedInstance] board];
        [unit setActionUsed:YES];        
        [board unit:unit attacksPos:self.boardPos];        
    }
    else if(!CGPointEqualToPoint(unit.boardPos, self.boardPos)) {

        [[BoardManager sharedInstance] setSelectedUnit:nil];
    }
}


@end
