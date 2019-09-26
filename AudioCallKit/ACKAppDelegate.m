/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "ACKAppDelegate.h"
#import "ACKMainViewController.h"
#import "UIExtensions.h"
#import <Intents/Intents.h>
#import "UIHelper.h"
#import "VoxApplication.h"

@implementation ACKAppDelegate

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.sharedClient = [[VIClient alloc] initWithDelegateQueue:dispatch_get_main_queue()];
        self.sharedAuthService = [[ACKAuthService alloc] initWithClient:self.sharedClient];
        self.sharedCallController = [[CXCallController alloc] initWithQueue:dispatch_get_main_queue()];
        self.sharedCallManager = [[ACKCallManager alloc] initWithClient:self.sharedClient authService:self.sharedAuthService];
        [self.sharedCallController.callObserver setDelegate:self queue:dispatch_get_main_queue()];
        // VIClient.writeLogsToFile()
        VIClient.logLevel = VILogLevelInfo;
        NSString *appVersion = [NSBundle.mainBundle.infoDictionary valueForKey:@"CFBundleShortVersionString"];
        NSLog(@"AudioCallKit Objective-C Demo v%@ started", appVersion);
    }
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UIApplication.sharedApplication.idleTimerDisabled = YES;
    return YES;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    if (self.sharedCallManager.managedCall) { return NO; }
    INIntent *startCallIntent = userActivity.interaction.intent;
    if (!startCallIntent) { return NO; }
    NSString *username;
    
    if (@available(iOS 13.0, *)) {
        INStartCallIntent *intent = (INStartCallIntent *)startCallIntent;
        username = intent.contacts.firstObject.personHandle.value;
    } else {
        INStartAudioCallIntent *intent = (INStartAudioCallIntent *)startCallIntent;
        username = intent.contacts.firstObject.personHandle.value;
    }
    if (!username) { return NO; }
    
    CXHandle *handle = [[CXHandle alloc] initWithType:CXHandleTypeGeneric value:username];
    CXStartCallAction *startCallAction = [[CXStartCallAction alloc] initWithCallUUID:[NSUUID new] handle:handle];
    CXTransaction *transaction = [[CXTransaction alloc] initWithAction:startCallAction];
    
    [self.sharedCallController requestTransaction:transaction completion:^(NSError * _Nullable error) {
        if (error) {
            [UIHelper showError:error.localizedDescription action:nil controller:nil];
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    return YES;
}

#pragma mark - AppLifeCycleDelegate
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

#pragma mark - CXCallObserverDelegate
- (void)callObserver:(CXCallObserver *)callObserver callChanged:(CXCall *)call {
    UIViewController *controller = self.window.rootViewController.toppestViewController;
    if ([controller conformsToProtocol:@protocol(CXCallObserverDelegate)]) {
        UIViewController <CXCallObserverDelegate> *protocolCastedController = (UIViewController <CXCallObserverDelegate> *)controller;
        [protocolCastedController callObserver:callObserver callChanged:call];
    };
}

@end
