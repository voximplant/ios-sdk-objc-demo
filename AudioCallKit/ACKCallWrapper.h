/*
*  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
*/

#import <VoxImplantSDK/VoxImplantSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface ACKCallWrapper : NSObject

// The call always nil on CallWrapper initialization
// It allows to handle the cases when the call can be reported to CallKit before the user is logged in, for example, the app received a VoIP push or a call is made from Recent Calls etc
@property (strong, nonatomic, readonly) VICall *call;
@property (strong, nonatomic, readonly) NSUUID *uuid;
@property (nonatomic) BOOL isOutgoing;
@property (nonatomic) BOOL hasConnected;

- (instancetype)initWitUUID:(NSUUID *)uuid isOutgoing:(BOOL)isOutgoing pushProcessingCompletion:(nullable dispatch_block_t)pushProcessingCompletion;
- (instancetype)initWithUUID:(NSUUID *)uuid isOutgoing:(BOOL)isOutgoing;
- (void)completePushProcessing;
- (void)setCall:(VICall *)call delegate:(id<VICallDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
