/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "ACAppDelegate.h"
#import "ACMainViewController.h"
#import "UIExtensions.h"

@implementation ACAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [VIClient setLogLevel:VILogLevelInfo];
    NSLog(@"Voximplant Objective-C Demo started");
    
    self.sharedClient = [[VIClient alloc] initWithDelegateQueue:dispatch_get_main_queue()];
    self.sharedAuthService = [[ACAuthService alloc] initWithClient:self.sharedClient];
    self.sharedCallManager = [[ACCallManager alloc] initWithClient:self.sharedClient authService:self.sharedAuthService];
    self.sharedCallManager.delegate = self;
    
    [UIApplication.sharedApplication setIdleTimerDisabled:NO];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [UIApplication.sharedApplication setIdleTimerDisabled:NO];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    UIViewController *navigationController = self.window.rootViewController;
    if ([navigationController isKindOfClass:[UINavigationController class]]) {
        UIViewController *controllerWithReconnect = ((UINavigationController *)navigationController).topViewController;
        if ([controllerWithReconnect isKindOfClass:[ACMainViewController class]]
            && controllerWithReconnect.presentedViewController == nil) {
            [(ACMainViewController *)controllerWithReconnect reconnect];
        }
    }
}

- (void)notifyIncomingCall:(VICall *)descriptor {
    UIViewController *controller = self.window.rootViewController.toppestViewController;
    if ([controller conformsToProtocol:@protocol(ACCallManagerDelegate)]) {
        UIViewController <ACCallManagerDelegate> *protocolCastedController = (UIViewController <ACCallManagerDelegate> *)controller;
        [protocolCastedController notifyIncomingCall:descriptor];
    }
}

@end
