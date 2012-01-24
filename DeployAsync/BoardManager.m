//
//  BoardManager.m
//  DeployAsync
//
//  Created by Vinit Agarwal on 1/23/12.
//  Copyright 2012 Zynga. All rights reserved.
//

#import "BoardManager.h"
#import "Unit.h"
#import "Board.h"

@implementation BoardManager

@synthesize board, selectedUnit;

static BoardManager *sharedInstance = nil;


+(BoardManager*) sharedInstance{
    @synchronized(self){
        if(sharedInstance == nil)
            sharedInstance = [[[self class] alloc] init];
    }
    return sharedInstance;   
}

- (void)setSelectedUnit:(Unit*)_selectedUnit {
    
    // Unhighlight previously selected unit
    if(selectedUnit) {
        [selectedUnit setHighlighted:NO];
    }
    selectedUnit = _selectedUnit;
    
    // Highlight newly selected unit
    [selectedUnit setHighlighted:YES];
    
    // Highlight moveable tiles
    [board highlightMovePoints:selectedUnit];
    [board highlightAttackPoints:selectedUnit];    
}


- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

@end
