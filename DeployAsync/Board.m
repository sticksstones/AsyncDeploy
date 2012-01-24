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

#import "BoardManager.h"
#import "PlayerManager.h"
#import "Hand.h"
#import "Deck.h"
#import "Card.h"
#import "HelloWorldLayer.h"

#define ROWS 9
#define COLUMNS 3
#define WIDTH_SPACING 10
#define HEIGHT_SPACING 0

@implementation Board

- (id)init
{
    self = [super init];
    if (self) {
        p1Tokens = [NSMutableArray new];
        p2Tokens = [NSMutableArray new];
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

- (void)setupBoard:(NSDictionary*)params {
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

- (void)moveUnit:(Unit*)unit toPos:(CGPoint)boardPos {
    
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
    
    //    CGPoint tileWorldCoords = [tile convertToWorldSpace:tile.position];
    
    //    [unit setPosition:tileWorldCoords];
    //    [unit setPosition:CGPointMake(tileWorldCoords.x, 
    //                                  ((CGSize)[[CCDirector sharedDirector] displaySizeInPixels]).height - tileWorldCoords.y)];
    CCActionEase* moveToTile = [CCActionEase actionWithAction:[CCMoveTo actionWithDuration:1.0 position:tile.position]];
    [unit runAction:moveToTile];
    
    [self wipeHighlighting];
    //[unit setPosition:tile.position];
    
}

- (void)unit:(Unit*)unit attacksPos:(CGPoint)boardPos {
    int tag;    
    Tile* tile;
    
    tag = [[NSString stringWithFormat:@"%d%d",(int)boardPos.x,(int)boardPos.y] intValue];    
    tile = (Tile*)[self getChildByTag:tag];
    
    if(tile) { // If tile exists
        Unit* occupyingUnit = [tile occupyingUnit];
        
        // Only if the tile is occupied and in attackable range
        if(occupyingUnit && [tile attackable]) {
            
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
                [self removeChild:occupyingUnit cleanup:YES];
                [tile setOccupyingUnit:nil];
            }
            
            // Do same for attacking unit
            if([unit HP] <= 0) {
                [self removeChild:unit cleanup:YES];
                CGPoint boardPos = [unit boardPos]; 
                int tag = [[NSString stringWithFormat:@"%d%d",(int)boardPos.x, (int)(boardPos.y)] intValue];
                Tile* unitTile = (Tile*)[self getChildByTag:tag];
                [unitTile setOccupyingUnit:nil];                
            }
            
            // Wipe the board of highlights
            [self wipeHighlighting];                        
        }
    }
    
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
        [tile setHighlighted:YES && ![tile occupied] && ![unit moveUsed]];
        
        tag = [[NSString stringWithFormat:@"%d%d",(int)boardPos.x, (int)(boardPos.y - x)] intValue];
        tile = (Tile*)[self getChildByTag:tag];
        [tile setHighlighted:YES && ![tile occupied] && ![unit moveUsed]];
        
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
    [tile setAttackable:[tile occupied] && [[tile occupyingUnit] playerNum] != [unit playerNum] && ![unit actionUsed]];
    
    tag = [[NSString stringWithFormat:@"%d%d",(int)boardPos.x, (int)(boardPos.y - attackRadius)] intValue];
    tile = (Tile*)[self getChildByTag:tag];
    [tile setAttackable:[tile occupied] && [[tile occupyingUnit] playerNum] != [unit playerNum] && ![unit actionUsed]];
    
    // Handle longer distance attackers that can attack across lanes
    if(attackRadius > 1) {
        tag = [[NSString stringWithFormat:@"%d%d",(int)boardPos.x - (attackRadius-1), (int)(boardPos.y)] intValue];
        tile = (Tile*)[self getChildByTag:tag];
        if(tile) {
            [tile setAttackable:[tile occupied] && [[tile occupyingUnit] playerNum] != [unit playerNum] && ![unit actionUsed]];
        }

        tag = [[NSString stringWithFormat:@"%d%d",(int)boardPos.x + (attackRadius-1), (int)(boardPos.y)] intValue];
        tile = (Tile*)[self getChildByTag:tag];
        if(tile) {
            [tile setAttackable:[tile occupied] && [[tile occupyingUnit] playerNum] != [unit playerNum] && ![unit actionUsed]];
        }
    }
}

- (void)addUnit:(Unit*)unit {
    int playerNum = [unit playerNum];
    NSMutableArray* tokenArray = playerNum == 1 ? p1Tokens : p2Tokens;
    
    [tokenArray addObject:unit];
    [unit setActionUsed:[unit playerNum] != [[PlayerManager sharedInstance] currentPlayer]];
    [unit setMoveUsed:[unit playerNum] != [[PlayerManager sharedInstance] currentPlayer]];
    
    [self addChild:unit];
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
    
    // Reset all units and make them movable/actionable again
    for(Unit* unit in tokenArray) {
        [unit setMoveUsed:NO];
        [unit setActionUsed:NO];
    }
    
    // Setup player
    [[PlayerManager sharedInstance] setCurrentPlayer:playerNum];
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

- (void)endTurn {
    int playerNum = [[PlayerManager sharedInstance] currentPlayer];
    NSArray* tokenArray = playerNum == 1 ? p1Tokens : p2Tokens;
    
    // Consume all moves/actions for all units
    for(Unit* unit in tokenArray) {
        [unit setMoveUsed:YES];
        [unit setActionUsed:YES];
    }    
    
    // Start a new turn for the other player
    [self startTurn:-1*playerNum];
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
