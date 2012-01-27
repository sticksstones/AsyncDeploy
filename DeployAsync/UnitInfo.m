//
//  UnitInfo.m
//  DeployAsync
//
//  Created by Vinit Agarwal on 1/26/12.
//  Copyright 2012 Zynga. All rights reserved.
//

#import "UnitInfo.h"
#import "cocos2d.h"
#import "Unit.h"

@implementation UnitInfo

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)setupWithUnit:(Unit*)unit {
    CCLabelTTF* label;
    
    label = [[CCLabelTTF alloc] initWithString:[[unit cardName] uppercaseString] fontName:@"Helvetica" fontSize:12.0];
    label.position = CGPointMake(self.contentSize.width/2, self.contentSize.height - label.contentSize.height);
    [self addChild:label];

    label = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"%d/%d",[unit AP],[unit maxHP]] fontName:@"Helvetica" fontSize:12.0];
    label.position = CGPointMake(self.contentSize.width - label.contentSize.width, label.contentSize.height);
    [self addChild:label];
    
    label = [[CCLabelTTF alloc] initWithString:[NSString stringWithFormat:@"%d/%d",[unit attackRadius],[unit moveRadius]] fontName:@"Helvetica" fontSize:12.0];
    label.position = CGPointMake(label.contentSize.width, label.contentSize.height);
    [self addChild:label];



}

@end
