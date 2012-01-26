//
//  BoardManager.h
//  DeployAsync
//
//  Created by Vinit Agarwal on 1/23/12.
//  Copyright 2012 Zynga. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Board;
@class Unit;

@interface BoardManager : NSObject {
    Board* board;
    Unit* selectedUnit;
}

@property (nonatomic, retain) Board* board;
@property (nonatomic, retain) Unit* selectedUnit;

+(BoardManager*)sharedInstance;
- (void)reset;


@end
