//
//  Unit.m
//  DeployAsync
//
//  Created by Vinit Agarwal on 1/23/12.
//  Copyright 2012 Zynga. All rights reserved.
//

#import "Unit.h"
#import "BoardManager.h"
#import "PlayerManager.h"
#import "MatchManager.h"
#import "Board.h"

#define kStatsLabel 100

#define kMoveAvail 200
#define kAttackAvail 300

@implementation Unit

@synthesize moveRadius, attackRadius, boardPos, playerNum, highlighted, moveUsed, actionUsed;
@synthesize HP, maxHP, AP, cardName;

- (id)init
{
    self = [super init];
    if (self) {
        CCLabelTTF* statsLabel = [[CCLabelTTF alloc] initWithString:@"0/0" fontName:@"Helvetica" fontSize:8.0];
        [self addChild:statsLabel z:1 tag:kStatsLabel];
        
        CCSprite* moveAvail = [CCSprite spriteWithFile:@"MoveAvail.png"];
        [self addChild:moveAvail z:1 tag:kMoveAvail];
        
        CCSprite* attackAvail = [CCSprite spriteWithFile:@"AttackAvail.png"];
        [self addChild:attackAvail z:1 tag:kAttackAvail];


        
        [self setAP:10];
        [self setHP:30];
        [self setMoveRadius:2];
        [self setAttackRadius:1];
        [self setPlayerNum:1];                
    }
    
    return self;
}

- (void)setMoveUsed:(_Bool)_moveUsed {
    moveUsed = _moveUsed;
    CCSprite* icon = (CCSprite*)[self getChildByTag:kMoveAvail];
    
    icon.position = CGPointMake(self.contentSize.width - 8, self.contentSize.height - 8);
    [icon setVisible:!moveUsed];
}

- (void)setActionUsed:(_Bool)_actionUsed {
    actionUsed = _actionUsed;
    CCSprite* icon = (CCSprite*)[self getChildByTag:kAttackAvail];
    
    icon.position = CGPointMake(self.contentSize.width - 8, 8);
    [icon setVisible:!actionUsed];    
}

- (id)initWithFile:(NSString *)filename {
    self = [super initWithFile:filename];
    [self updateStatsLabel];
    return self;
}

- (void)updateStatsLabel {
    CCLabelTTF* statsLabel = (CCLabelTTF*)[self getChildByTag:kStatsLabel];
    
    [statsLabel setPosition:CGPointMake(self.contentSize.width/2, self.contentSize.height/2)];    
    [statsLabel setString:[NSString stringWithFormat:@"%d/%d",AP,HP]];
}

- (void)setMaxHP:(int)_maxHP {
    maxHP = _maxHP;
    if(HP > maxHP) {
        self.HP = maxHP;
    }
}

- (void)setHP:(int)_HP {
    HP = _HP;
    [self updateStatsLabel];
}

- (void)setAP:(int)_AP {
    AP = _AP;
    [self updateStatsLabel];
}

- (void)setHighlighted:(_Bool)_highlighted {
    highlighted = _highlighted;
    self.opacity = highlighted ? 255 : 128;
}

- (void)setPlayerNum:(int)_playerNum {
    playerNum = _playerNum;
    self.color = playerNum == 1 ? ccBLUE : ccRED;
}

- (void)damage:(int)amount {
    self.HP -= amount;
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
    
    if([[PlayerManager sharedInstance] thisPlayersTurn] && playerNum == [[PlayerManager sharedInstance] currentPlayer] && ![[MatchManager sharedInstance] showingRecap]) {
        [[BoardManager sharedInstance] setSelectedUnit:self];
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
    //CGPoint touchPoint = [touch locationInView:[touch view]];
}

- (void)setupFromCardParams:(NSDictionary*)params {
    int _HP = [[params valueForKey:@"hp"] intValue];
    int _AP = [[params valueForKey:@"ap"] intValue];
    int _moveRadius = [[params valueForKey:@"moveRadius"] intValue];
    int _attackRadius = [[params valueForKey:@"attackRadius"] intValue];
    
    [self setCardName:[params valueForKey:@"name"]];    
    [self setHP:_HP];
    [self setMaxHP:_HP];
    [self setAP:_AP];
    [self setMoveRadius:_moveRadius];
    [self setAttackRadius:_attackRadius];
    
}


- (void)setupUnit:(NSDictionary*)state {
    NSString* card = [state valueForKey:@"cardName"];
    
    
    NSString * plistPath = [[NSBundle mainBundle] pathForResource:@"CardData" ofType:@"plist"];
    NSDictionary* cardsData = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSMutableDictionary* cardData = [[NSMutableDictionary alloc] initWithDictionary:[cardsData objectForKey:card]];
    [cardData setValue:card forKey:@"name"];
    
    [self setupFromCardParams:cardData];

    
    [self setPlayerNum:[[state valueForKey:@"owner"] intValue]];
    [self setHP:[[state valueForKey:@"HP"] intValue]];
    
    int boardX = [[state valueForKey:@"BOARD_X"] intValue];
    int boardY = [[state valueForKey:@"BOARD_Y"] intValue];
    
    [self setBoardPos:CGPointMake(boardX, boardY)];
    
}



- (NSDictionary*)serialize {
    NSMutableDictionary* serialized = [NSMutableDictionary new];
    [serialized setValue:cardName forKey:@"cardName"];
    [serialized setValue:[NSNumber numberWithInt:HP] forKey:@"HP"];
    [serialized setValue:[NSNumber numberWithInt:boardPos.x] forKey:@"BOARD_X"];
    [serialized setValue:[NSNumber numberWithInt:boardPos.y] forKey:@"BOARD_Y"]; 
    [serialized setValue:[NSNumber numberWithInt:[self playerNum]] forKey:@"owner"]; 
    
    return serialized;
}

@end
