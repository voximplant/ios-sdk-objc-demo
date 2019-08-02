/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import <UIKit/UIKit.h>
#import "ACAuthService.h"
#import "ACCallManager.h"
#import <VoxImplant/VoxImplant.h>

#define AppDelegateMacros ((ACAppDelegate *)[UIApplication sharedApplication].delegate)

NS_ASSUME_NONNULL_BEGIN

@interface ACAppDelegate : UIResponder<UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, atomic) ACAuthService *sharedAuthService;
@property (strong, atomic) VIClient *sharedClient;
@property (strong, atomic) ACCallManager *sharedCallManager;

@end

NS_ASSUME_NONNULL_END
