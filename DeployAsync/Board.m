//
//  Board.m
//  DeployAsync
//
//  Created by Vinit Agarwal on 1/23/12.
//  Copyright 2012 Zynga. All rights reserved.
//

#import "Board.h"
#import "Tile.h"
#import "Unit.h"
#import "Crystal.h"

#import "BoardManager.h"
#import "PlayerManager.h"
#import "Hand.h"
#import "Deck.h"
#import "Card.h"
#import "HelloWorldLayer.h"

#import "MatchManager.h"

#define ROWS 9
#define COLUMNS 3
#define WIDTH_SPACING 10
#define HEIGHT_SPACING 0

#define CRYSTAL_HP 50

@implementation Board

@synthesize boardName;

- (id)init
{
    self = [super init];
    if (self) {
        p1Tokens = [NSMutableArray new];
        p2Tokens = [NSMutableArray new];
        p1Crystals = [NSMutableArray new];
        p2Crystals = [NSMutableArray new];        
        
        self.contentSize = CGSizeMake(200, 475);
        
        
        // Calculate offset/spacing info
        CGSize tileSpacing = CGSizeMake((self.contentSize.width + WIDTH_SPACING)/(COLUMNS), 
                                        (self.contentSize.height + HEIGHT_SPACING)/(ROWS));
        
        Tile* referenceTile = [[Tile alloc] initWithFile:@"Tile.png"]; 
        
        float widthAlign = (self.contentSize.width - ((COLUMNS-1)*tileSpacing.width + referenceTile.contentSize.width))/2;
        float heightAlign = (self.contentSize.height - ((ROWS-1)*tileSpacing.height + referenceTile.contentSize.height))/2; 
        
        
        // Create the tiles
        for(int x = 1; x <= COLUMNS; ++x) {
            for(int y = 1; y <= ROWS; ++y) {
                Tile* tile = [[Tile alloc] initWithFile:@"Tile.png"];
                tile.position = CGPointMake(widthAlign + tile.contentSize.width/2 + (x-1)*tileSpacing.width,
                                            heightAlign + tile.contentSize.height/2 + (y-1)*tileSpacing.height);
                
                [tile setBoardPos:CGPointMake(x,y)];
                int tag = [[NSString stringWithFormat:@"%d%d",x,y] intValue];
                [self addChild:tile z:0 tag:tag];
            }
        }
    }    
    return self;
}

- (NSArray*)getCrystalsForPlayer:(int)playerNum {
    NSArray* tokenArray = playerNum == 1 ? p1Crystals : p2Crystals;
    
    NSMutableArray* serializedTokens = [NSMutableArray new];
    
    for(Crystal* crystal in tokenArray) {
        NSDictionary* crystalState = [crystal serialize];
        [serializedTokens addObject:crystalState];
    }
    
    return serializedTokens;
    
}

- (void)setCrystals:(NSArray*)crystals forPlayer:(int)playerNum {
    NSMutableArray* tokenArray = playerNum == 1 ? p1Crystals : p2Crystals;
    
    
    for(Crystal* crystal in tokenArray) {
        [self removeChild:crystal cleanup:YES];
    }
    
    [tokenArray removeAllObjects];
    
    for(NSDictionary* crystalState in crystals) {
        Crystal* crystal = [[Crystal alloc] initWithFile:@"Crystal.png"];
        [crystal setupCrystal:crystalState];
        
        Tile* tile = (Tile*)[self getChildByTag:(int)(crystal.boardPos.x*10 + crystal.boardPos.y)];
        crystal.maxHP = CRYSTAL_HP;
        crystal.position = tile.position;
        tile.crystal = crystal;        
        [self addCrystal:crystal];        
    }
    
}

- (NSArray*)getTokensForPlayer:(int)playerNum {
    NSArray* tokenArray = playerNum == 1 ? p1Tokens : p2Tokens;
    
    NSMutableArray* serializedTokens = [NSMutableArray new];
    
    for(Unit* unit in tokenArray) {
        NSDictionary* unitState = [unit serialize];
        [serializedTokens addObject:unitState];
    }
    
    return serializedTokens;
}

- (void)setTokens:(NSArray*)tokens forPlayer:(int)playerNum {
    NSMutableArray* tokenArray = playerNum == 1 ? p1Tokens : p2Tokens;
    
    
    for(Unit* unit in tokenArray) {
        [self removeChild:unit cleanup:YES];
    }
    
    [tokenArray removeAllObjects];
    
    for(NSDictionary* unitState in tokens) {
        Unit* unit = [[Unit alloc] initWithFile:@"Unit.png"];
        [unit setupUnit:unitState];
        [self addUnit:unit];
        Tile* tile = (Tile*)[self getChildByTag:(int)(unit.boardPos.x*10 + unit.boardPos.y)];
        unit.position = CGPointMake(tile.position.x, tile.position.y);
        [self moveUnit:unit toPos:unit.boardPos];
    }
}

- (void)resetTiles {
    for(int x = 1; x <= COLUMNS; ++x) {
        for(int y = 1; y <= ROWS; ++y) {
            int tag = [[NSString stringWithFormat:@"%d%d",x,y] intValue];
            
            Tile* tile = (Tile*)[self getChildByTag:tag];
            if(tile) {
                [tile reset];
            }
        }
    }
    
}

- (void)setupBoard:(NSDictionary*)params {
    
    [self resetTiles];
    
    for(NSString* tileKey in [params allKeys]) {
        int tag = [tileKey intValue];
        NSString* tileProperty = [params valueForKey:tileKey];
        Tile* tile = (Tile*)[self getChildByTag:tag];
        
        if([tileProperty isEqualToString:@"mana"]) {
            
            [tile setManaValue:1];
        }
        else if([tileProperty isEqualToString:@"double mana"]) {
            [tile setManaValue:2];
        }
    }
    
    
    // Add the crystals for both players
    for(int x = 1; x <= COLUMNS; ++x) {
        Crystal* crystal;    
        crystal = [[Crystal alloc] initWithFile:@"Crystal.png"];
        crystal.playerNum = -1;
        crystal.HP = CRYSTAL_HP;
        crystal.maxHP = CRYSTAL_HP;
        crystal.boardPos = CGPointMake(x, ROWS);
        Tile* tile;
        tile = (Tile*)[self getChildByTag:(x*10 + ROWS)];
        crystal.position = tile.position;
        tile.crystal = crystal;
        [self addCrystal:crystal];
        
        
        crystal = [[Crystal alloc] initWithFile:@"Crystal.png"];
        crystal.playerNum = 1;
        crystal.HP = CRYSTAL_HP;
        crystal.maxHP = CRYSTAL_HP;
        crystal.boardPos = CGPointMake(x, 1);
        tile = (Tile*)[self getChildByTag:(x*10 + 1)];
        crystal.position = tile.position;
        tile.crystal = crystal;        
        [self addCrystal:crystal];
    }
}

- (void)wipeHighlighting {
    for(int x = 1; x <= COLUMNS; ++x) {
        for(int y = 1; y <= ROWS; ++y) {
            int tag = [[NSString stringWithFormat:@"%d%d",x,y] intValue];
            
            Tile* tile = (Tile*)[self getChildByTag:tag];
            if(tile) {
                [tile setHighlighted:NO];
                [tile setAttackable:NO];
            }
        }
    }
}

- (void)LOGGEDmoveUnit:(Unit*)unit toPos:(CGPoint)boardPos {
    CGPoint origBoardPos = [unit boardPos];
    if([self moveUnit:unit toPos:boardPos]) {
        // Log the event
        // Format: move src_tile dest_tile    
        [[MatchManager sharedInstance] queueMove:[NSString stringWithFormat:@"move|%d%d|%d%d", (int)(origBoardPos.x),(int)(origBoardPos.y),(int)boardPos.x,(int)boardPos.y]];            
    }
}

- (bool)moveUnit:(Unit*)unit toPos:(CGPoint)boardPos {
    
    // Unoccupy unit's current tile
    CGPoint origBoardPos = [unit boardPos];
    int tag;    
    Tile* tile;
    
    tag = [[NSString stringWithFormat:@"%d%d",(int)origBoardPos.x,(int)origBoardPos.y] intValue];    
    tile = (Tile*)[self getChildByTag:tag];
    [tile setOccupied:NO];
    
    
    // Occupy new tile
    [unit setBoardPos:boardPos];
    
    tag = [[NSString stringWithFormat:@"%d%d",(int)boardPos.x,(int)boardPos.y] intValue];    
    tile = (Tile*)[self getChildByTag:tag];
    [tile setOccupied:YES];
    [tile setOccupyingUnit:unit];
    
    CCActionEase* moveToTile = [CCActionEase actionWithAction:[CCMoveTo actionWithDuration:1.0 position:tile.position]];
    
    //CCSequence* seq = [CCSequence actions:moveToTile,[CCCallFunc actionWithTarget:[MatchManager sharedInstance] selector:@selector(popMove:)],nil];
    [unit runAction:moveToTile];
    
    [self wipeHighlighting];
    return YES;
    
}

- (void)LOGGEDunit:(Unit*)unit attacksPos:(CGPoint)boardPos  {
    if([self unit:unit attacksPos:boardPos]) {
        // Log the event
        // Format: atk src_unit_pos dest_unit_pos
        [[MatchManager sharedInstance] queueMove:[NSString stringWithFormat:@"atk|%d%d|%d%d", (int)(unit.boardPos.x),(int)(unit.boardPos.y),(int)boardPos.x,(int)boardPos.y]];        
    }
}

- (void)removeCrystal:(Crystal *)crystal {
    int crystalOwner = [crystal playerNum];
    int winner = -1*crystalOwner;
    
    bool thisPlayerWon = [[PlayerManager sharedInstance] currentPlayer] == winner && [[PlayerManager sharedInstance] thisPlayersTurn];
    
    
    GKTurnBasedMatch *currentMatch = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
    for (GKTurnBasedParticipant *part in currentMatch.participants) {
        if([part.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
            if(thisPlayerWon) {
                part.matchOutcome = GKTurnBasedMatchOutcomeWon;
            }
            else {
                part.matchOutcome = GKTurnBasedMatchOutcomeLost;
            }
        }
        else {
            if(thisPlayerWon) {
                part.matchOutcome = GKTurnBasedMatchOutcomeLost;            
            }
            else {
                part.matchOutcome = GKTurnBasedMatchOutcomeWon;
            }
        }
    }
    [currentMatch endMatchInTurnWithMatchData:[[MatchManager sharedInstance] serialize] completionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        }
    }];
    
    
    int playerNum = [crystal playerNum];
    NSMutableArray* tokenArray = playerNum == 1 ? p1Crystals : p2Crystals;
    
    [tokenArray removeObject:crystal];        
    [self removeChild:crystal cleanup:YES];

    

}

- (bool)unit:(Unit*)unit attacksPos:(CGPoint)boardPos {
    int tag;    
    Tile* tile;
    
    tag = [[NSString stringWithFormat:@"%d%d",(int)boardPos.x,(int)boardPos.y] intValue];    
    tile = (Tile*)[self getChildByTag:tag];
    
    if(tile) { // If tile exists
        
        Crystal* crystal = [tile crystal];
        if(crystal) {
            [crystal damage:[unit AP]];
            
            if([crystal HP] <= 0) {
                [self removeCrystal:crystal];
                [tile setCrystal:nil];
            }
            [self wipeHighlighting];        
            
            return YES;
        }
        else {
            
            Unit* occupyingUnit = [tile occupyingUnit];
            
            // Only if the tile is occupied and in attackable range
            if(occupyingUnit) {
                
                
                // Damage enemy unit
                [occupyingUnit damage:[unit AP]];
                
                // Enemy unit damages back (if in range)
                if((int)(fabs([unit boardPos].y - [occupyingUnit boardPos].y)) <= [occupyingUnit attackRadius]) {
                    if((int)(fabs([unit boardPos].x - [occupyingUnit boardPos].x)) <= [occupyingUnit attackRadius]-1) {
                        [unit damage:[occupyingUnit AP]];
                    }
                }
                
                // If enemy unit is dead, remove
                if([occupyingUnit HP] <= 0) {
                    [self removeUnit:occupyingUnit];
                    [tile setOccupyingUnit:nil];
                }
                
                // Do same for attacking unit
                if([unit HP] <= 0) {
                    [self removeUnit:unit];
                    CGPoint boardPos = [unit boardPos]; 
                    int tag = [[NSString stringWithFormat:@"%d%d",(int)boardPos.x, (int)(boardPos.y)] intValue];
                    Tile* unitTile = (Tile*)[self getChildByTag:tag];
                    [unitTile setOccupyingUnit:nil];                
                }
                
                // Wipe the board of highlights
                [self wipeHighlighting];        
                
                
                
                //            CCSequence* seq = [CCSequence actions:[CCDelayTime actionWithDuration:2.0], [CCCallFunc actionWithTarget:[MatchManager sharedInstance] selector:@selector(popMove:)],nil];
                //            [self runAction:seq];
                //            
                
                return YES;
            }
        }
    }
    return NO;
    
}


- (void)removeUnit:(Unit*)unit {
    int playerNum = [unit playerNum];
    NSMutableArray* tokenArray = playerNum == 1 ? p1Tokens : p2Tokens;
    
    [tokenArray removeObject:unit];        
    [self removeChild:unit cleanup:YES];
}

- (void)highlightRow:(int)row {
    for(int x = 1; x <= COLUMNS; ++x) {
        int tag = [[NSString stringWithFormat:@"%d%d",x,row] intValue];
        
        Tile* tile = (Tile*)[self getChildByTag:tag];
        if(tile) {
            [tile setHighlighted:YES && ![tile occupied]];
        }
    }
    
}

- (void)highlightSpawnPoints:(int)playerNum {
    [self wipeHighlighting];
    if(playerNum == 1) {
        [self highlightRow:1];
    }
    else if(playerNum == -1) {
        [self highlightRow:ROWS];
    }
}

- (void)highlightMovePoints:(Unit*)unit {
    [self wipeHighlighting]; // Remove all tile highlighting
    
    CGPoint boardPos = [unit boardPos]; 
    int moveRadius = [unit moveRadius];
    
    // Run through all tiles from unit's pos to move radius and highlight
    for(int x = 1; x <= moveRadius; ++x) {
        Tile* tile;
        int tag;
        
        // Set +/- tiles to highlighted
        tag = [[NSString stringWithFormat:@"%d%d",(int)boardPos.x, (int)(boardPos.y + x)] intValue];
        tile = (Tile*)[self getChildByTag:tag];
        [tile setHighlighted:![tile occupied] && ![unit moveUsed] && (!([tile crystal] && [[tile crystal] playerNum] != [unit playerNum]))];
        
        tag = [[NSString stringWithFormat:@"%d%d",(int)boardPos.x, (int)(boardPos.y - x)] intValue];
        tile = (Tile*)[self getChildByTag:tag];
        [tile setHighlighted:![tile occupied] && ![unit moveUsed] && (!([tile crystal] && [[tile crystal] playerNum] != [unit playerNum]))];
        
    }
    
}

- (void)highlightAttackPoints:(Unit*)unit {
    //[self wipeHighlighting]; // Remove all tile highlighting
    
    CGPoint boardPos = [unit boardPos]; 
    int attackRadius = [unit attackRadius];
    
    // Highlight the tiles that are attackRadius away from the player and have a unit to attack in them
    Tile* tile;
    int tag;
    
    // Set +/- tiles to highlighted
    tag = [[NSString stringWithFormat:@"%d%d",(int)boardPos.x, (int)(boardPos.y + attackRadius)] intValue];
    tile = (Tile*)[self getChildByTag:tag];
    [tile checkAttackable:unit];
    
    tag = [[NSString stringWithFormat:@"%d%d",(int)boardPos.x, (int)(boardPos.y - attackRadius)] intValue];
    tile = (Tile*)[self getChildByTag:tag];
    [tile checkAttackable:unit];
    
    // Handle longer distance attackers that can attack across lanes
    if(attackRadius > 1) {
        tag = [[NSString stringWithFormat:@"%d%d",(int)boardPos.x - (attackRadius-1), (int)(boardPos.y)] intValue];
        tile = (Tile*)[self getChildByTag:tag];
        if(tile) {
            [tile checkAttackable:unit];
        }
        
        tag = [[NSString stringWithFormat:@"%d%d",(int)boardPos.x + (attackRadius-1), (int)(boardPos.y)] intValue];
        tile = (Tile*)[self getChildByTag:tag];
        if(tile) {
            [tile checkAttackable:unit];
        }
    }
}

- (void)addCrystal:(Crystal*)crystal {
    int playerNum = [crystal playerNum];
    NSMutableArray* crystalArray = playerNum == 1 ? p1Crystals : p2Crystals;
    
    [crystalArray addObject:crystal];
    
    [self addChild:crystal];
}

- (void)addUnit:(Unit*)unit {
    int playerNum = [unit playerNum];
    NSMutableArray* tokenArray = playerNum == 1 ? p1Tokens : p2Tokens;
    
    [tokenArray addObject:unit];
    [unit setActionUsed:[unit playerNum] != [[PlayerManager sharedInstance] currentPlayer]];
    [unit setMoveUsed:[unit playerNum] != [[PlayerManager sharedInstance] currentPlayer]];
    
    [self addChild:unit];
}

- (void)setUnit:(Unit*)unit AtBoardPos:(CGPoint)boardPos {
    int tag = [[NSString stringWithFormat:@"%d%d",(int)boardPos.x,(int)boardPos.y] intValue];
    
    Tile* tile = (Tile*)[self getChildByTag:tag];
    if(tile) {
        unit.position = tile.position;
    }
}

- (Unit*)getUnitAtBoardPos:(CGPoint)boardPos {
    int tag = [[NSString stringWithFormat:@"%d%d",(int)boardPos.x,(int)boardPos.y] intValue];
    
    Tile* tile = (Tile*)[self getChildByTag:tag];
    if(tile) {
        return tile.occupyingUnit;
    }
    
    return nil;
}

- (void)awardMana {
    [[PlayerManager sharedInstance] setManaMax:2];
    for(int x = 1; x <= COLUMNS; ++x) {
        for(int y = 1; y <= ROWS; ++y) {
            int tag = [[NSString stringWithFormat:@"%d%d",x,y] intValue];
            
            Tile* tile = (Tile*)[self getChildByTag:tag];
            if(tile) {
                
                Unit* occupyingUnit = [tile occupyingUnit];
                if(occupyingUnit && [occupyingUnit playerNum] == [[PlayerManager sharedInstance] currentPlayer]) {
                    [[PlayerManager sharedInstance] bumpManaMax:[tile manaValue]];
                }
            }
        }
    }
    
}

- (void)startTurn:(int)playerNum {
    NSArray* tokenArray = playerNum == 1 ? p1Tokens : p2Tokens;
    
    // Reset board state
    [self wipeHighlighting];    
    [[BoardManager sharedInstance] setSelectedUnit:nil];
    
    bool thisPlayer = [[PlayerManager sharedInstance] thisPlayersTurn];
    
    // Reset all units and make them movable/actionable again (if it's this player's turn)
    for(Unit* unit in tokenArray) {
        [unit setMoveUsed:!thisPlayer];
        [unit setActionUsed:!thisPlayer];
    }
    
    // Setup player    
    if(thisPlayer) {
        [self awardMana];
        [[PlayerManager sharedInstance] resetMana];    
        
        // Draw a new card into the hand
        Hand* hand = [[PlayerManager sharedInstance] hand];        
        Deck* deck = [[PlayerManager sharedInstance] deck];
        
        Card* card = [deck drawCard];
        if(card) {
            [hand addCard:card];        
        }
    }
    else {
        // Fizzle mana
        //[[PlayerManager sharedInstance] setMana:0];
    }
}

- (void)endTurn {
    int playerNum = [[PlayerManager sharedInstance] currentPlayer];
    NSArray* tokenArray = playerNum == 1 ? p1Tokens : p2Tokens;
    
    // Consume all moves/actions for all units
    for(Unit* unit in tokenArray) {
        [unit setMoveUsed:YES];
        [unit setActionUsed:YES];
    }    
    
    // Send game-state
    NSData* gameState = [[MatchManager sharedInstance] serializeMoveList];
    
    GKTurnBasedMatch *currentMatch = [[GCTurnBasedMatchHelper sharedInstance] currentMatch];
    
    NSUInteger currentIndex = [currentMatch.participants indexOfObject:currentMatch.currentParticipant];
    GKTurnBasedParticipant *nextParticipant;
    
    NSUInteger nextIndex = (currentIndex + 1) % [currentMatch.participants count];
    nextParticipant = [currentMatch.participants objectAtIndex:nextIndex];
    
    for (int i = 0; i < [currentMatch.participants count]; i++) {
        nextParticipant = [currentMatch.participants objectAtIndex:((currentIndex + 1 + i) % [currentMatch.participants count ])];
        if (nextParticipant.matchOutcome != GKTurnBasedMatchOutcomeQuit) {
            NSLog(@"isnt' quit %@", nextParticipant);
            break;
        } else {
            NSLog(@"nex part %@", nextParticipant);
        }
    }

    [currentMatch endTurnWithNextParticipant:nextParticipant matchData:gameState completionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
        }
    }];
    NSLog(@"Send Turn, %@, %@", gameState, nextParticipant);
    
    
    // Start a new turn for the other player
    //[self startTurn:-1*playerNum];
}

- (CGPoint)getBoardPosForTouch:(UITouch*)touch {
    for(int x = 1; x <= COLUMNS; ++x) {
        for(int y = 1; y <= ROWS; ++y) {
            int tag = [[NSString stringWithFormat:@"%d%d",x,y] intValue];
            
            Tile* tile = (Tile*)[self getChildByTag:tag];
            if(tile) {
                if([tile containsTouchLocation:touch]) {
                    return [tile boardPos];
                }
            }
        }
    }
    return CGPointZero;
    
}

- (bool)isValidSpawnPoint:(CGPoint)boardPos {    
    int tag = [[NSString stringWithFormat:@"%d%d",(int)boardPos.x,(int)boardPos.y] intValue];
    
    Tile* tile = (Tile*)[self getChildByTag:tag];
    
    if(tile) {
        return [tile highlighted];
    }
    return NO;
}


@end
