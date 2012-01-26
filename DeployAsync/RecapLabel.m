//
//  RecapLabel.m
//  DeployAsync
//
//  Created by Vinit Agarwal on 1/25/12.
//  Copyright 2012 Zynga. All rights reserved.
//

#import "RecapLabel.h"
#import "MatchManager.h"

@implementation RecapLabel

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.

    }
    
    return self;
}

- (void)kill {
    [self removeFromParentAndCleanup:YES];
}

void ccDrawFilledRect( CGPoint v1, CGPoint v2 )
{
	CGPoint poli[]={v1,CGPointMake(v1.x,v2.y),v2,CGPointMake(v2.x,v1.y)};
    
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_VERTEX_ARRAY,
	// Unneeded states: GL_TEXTURE_2D, GL_TEXTURE_COORD_ARRAY, GL_COLOR_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
    
	glVertexPointer(2, GL_FLOAT, 0, poli);
	glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    
	// restore default state
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
}

- (void)draw {
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    glColor4ub(0, 150, 0, self.opacity);
    ccDrawFilledRect(CGPointMake(0,self.contentSize.height), CGPointMake(self.contentSize.width, 0));
    
    [super draw];
}

@end
