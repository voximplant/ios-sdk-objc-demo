/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "ACKAppDelegate.h"
#import "ACKMainViewController.h"
#import "UIExtensions.h"

@implementation ACKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    VIClient.logLevel = VILogLevelInfo;
    NSLog(@"Voximplant Objective-C Demo started");
    
    self.sharedClient = [[VIClient alloc] initWithDelegateQueue:dispatch_get_main_queue()];
    self.sharedAuthService = [[ACKAuthService alloc] initWithClient:self.sharedClient];
    self.sharedCallManager = [[ACKCallManager alloc] initWithClient:self.sharedClient authService:self.sharedAuthService];
    self.sharedCallController = [[CXCallController alloc] initWithQueue:dispatch_get_main_queue()];
    
    [self.sharedCallController.callObserver setDelegate:self queue:dispatch_get_main_queue()];
    
    UIApplication.sharedApplication.idleTimerDisabled = NO;
    return YES;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {

    return YES;
}


#pragma mark AppLifeCycleDelegate
- (void)applicationWillResignActive:(UIApplication *)application {
    UIViewController *controller = self.window.rootViewController.toppestViewController;
    if ([controller conformsToProtocol:@protocol(AppLifeCycleDelegate)]) {
        UIViewController <AppLifeCycleDelegate> *protocolCastedController = (UIViewController <AppLifeCycleDelegate> *)controller;
        if ([protocolCastedController respondsToSelector:@selector(applicationWillResignActive:)]) {
            [protocolCastedController applicationWillResignActive:application];
        }
    }
    UIApplication.sharedApplication.idleTimerDisabled = NO;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    UIViewController *controller = self.window.rootViewController.toppestViewController;
    if ([controller conformsToProtocol:@protocol(AppLifeCycleDelegate)]) {
        UIViewController <AppLifeCycleDelegate> *protocolCastedController = (UIViewController <AppLifeCycleDelegate> *)controller;
        if ([protocolCastedController respondsToSelector:@selector(applicationDidEnterBackground:)]) {
            [protocolCastedController applicationDidEnterBackground:application];
        }
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    UIViewController *controller = self.window.rootViewController.toppestViewController;
    if ([controller conformsToProtocol:@protocol(AppLifeCycleDelegate)]) {
        UIViewController <AppLifeCycleDelegate> *protocolCastedController = (UIViewController <AppLifeCycleDelegate> *)controller;
        if ([protocolCastedController respondsToSelector:@selector(applicationWillEnterForeground:)]) {
            [protocolCastedController applicationWillEnterForeground:application];
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    UIViewController *controller = self.window.rootViewController.toppestViewController;
    if ([controller conformsToProtocol:@protocol(AppLifeCycleDelegate)]) {
        UIViewController <AppLifeCycleDelegate> *protocolCastedController = (UIViewController <AppLifeCycleDelegate> *)controller;
        if ([protocolCastedController respondsToSelector:@selector(applicationDidBecomeActive:)]) {
            [protocolCastedController applicationDidBecomeActive:application];
        }
    }
}

#pragma mark CXCallObserverDelegate
- (void)callObserver:(CXCallObserver *)callObserver callChanged:(CXCall *)call {
    UIViewController *controller = self.window.rootViewController.toppestViewController;
    if ([controller conformsToProtocol:@protocol(CXCallObserverDelegate)]) {
        UIViewController <CXCallObserverDelegate> *protocolCastedController = (UIViewController <CXCallObserverDelegate> *)controller;
        [protocolCastedController callObserver:callObserver callChanged:call];
    };
}

@end
