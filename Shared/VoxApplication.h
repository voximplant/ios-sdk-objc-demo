/*
*  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
*/

#import <UIKit/UIKit.h>

@protocol AppLifeCycleDelegate <NSObject>

@optional
- (void)applicationWillResignActive:(UIApplication *)application;
- (void)applicationDidEnterBackground:(UIApplication *)application;
- (void)applicationWillEnterForeground:(UIApplication *)application;
- (void)applicationDidBecomeActive:(UIApplication *)application;

@end
