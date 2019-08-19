/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <PushKit/PushKit.h>
#import "ACKAuthService.h"
#import <VoxImplant/VoxImplant.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ACKPushCallNotifierDelegate <NSObject>

- (void)handlePushIncomingCall:(NSDictionary *)callDescription
                    completion:(void(^)(NSString *_Nullable result, NSError *_Nullable error))completion;

@end

dispatch_block_t pushNotificationCompletion;

@interface ACKPushCallNotifier : NSObject<PKPushRegistryDelegate>

- (instancetype)initPushNotifierWithClient:(VIClient *)client authService:(ACKAuthService *)authService;

@end

NS_ASSUME_NONNULL_END
