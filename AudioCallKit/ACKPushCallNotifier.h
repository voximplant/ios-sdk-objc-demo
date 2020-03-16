/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <PushKit/PushKit.h>
#import "ACKAuthService.h"
@import VoxImplantSDK;

NS_ASSUME_NONNULL_BEGIN

@protocol ACKPushCallNotifierDelegate <NSObject>

-(void)didReceiveIncomingCall:(NSUUID *)uuid from:(NSString *)fullUsername with:(NSString *)displayName with:(dispatch_block_t)completion;

@end

@interface ACKPushCallNotifier: NSObject<PKPushRegistryDelegate>

@property (weak, atomic) id<ACKPushCallNotifierDelegate> delegate;

- (instancetype)initPushNotifierWithClient:(VIClient *)client authService:(ACKAuthService *)authService;

@end

NS_ASSUME_NONNULL_END
