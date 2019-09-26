/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "ACAuthService.h"
#import <VoxImplant/VoxImplant.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ACCallManagerDelegate <NSObject>

-(void)notifyIncomingCall:(VICall *)descriptor;

@end

@interface ACCallManager : NSObject<VIClientCallManagerDelegate, VICallDelegate>

@property (weak, atomic) id<ACCallManagerDelegate> delegate;
@property (nonatomic, strong, nullable) VICall *managedCall;

- (instancetype)initWithClient:(VIClient *)client authService:(ACAuthService *)authService;
- (void)startOutgoingCallWithContact:(NSString *)contact completion:(void (^)(NSError *_Nullable error))completion;
- (void)makeIncomingCallActive;

@end

NS_ASSUME_NONNULL_END
