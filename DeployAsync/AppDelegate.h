//
//  AppDelegate.h
//  DeployAsync
//
//  Created by Vinit Agarwal on 1/23/12.
//  Copyright Zynga 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
