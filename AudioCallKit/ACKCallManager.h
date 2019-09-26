/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "ACKAuthService.h"
#import <VoxImplant/VoxImplant.h>
#import <CallKit/CallKit.h>
#import <PushKit/PushKit.h>
#import "ACKCallWrapper.h"
#import "ACKPushCallNotifier.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACKCallManager : NSObject<CXProviderDelegate, VIClientCallManagerDelegate, VICallDelegate, ACKPushCallNotifierDelegate>

@property (nonatomic, strong, nullable) ACKCallWrapper *managedCall;

- (instancetype)initWithClient:(VIClient *)client authService:(ACKAuthService *)authService;

@end

NS_ASSUME_NONNULL_END
