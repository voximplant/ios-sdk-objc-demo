/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import <UIKit/UIKit.h>
#import "ACKAuthService.h"
#import "ACKCallManager.h"
#import <VoxImplant/VoxImplant.h>
#import <CallKit/CallKit.h>

#define AppDelegateMacros ((ACKAppDelegate *)[UIApplication sharedApplication].delegate)

NS_ASSUME_NONNULL_BEGIN

@interface ACKAppDelegate : UIResponder<UIApplicationDelegate, CXCallObserverDelegate>

@property (strong, atomic) VIClient *sharedClient;
@property (strong, atomic) ACKAuthService *sharedAuthService;
@property (strong, atomic) CXCallController *sharedCallController;
@property (strong, atomic) ACKCallManager *sharedCallManager;
@property (strong, nonatomic) UIWindow *window;

@end

NS_ASSUME_NONNULL_END
