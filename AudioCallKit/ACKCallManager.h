/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "ACKAuthService.h"
#import <VoxImplant/VoxImplant.h>
#import <CallKit/CallKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CallManagerDelegate <NSObject>

-(void)notifyIncomingCall:(VICall *)descriptor;

@end

@interface ACKCallWrapper : NSObject

@property (strong, nonatomic) VICall *call;
@property (strong, nonatomic) NSUUID *uuid;
@property (nonatomic) BOOL isOutgoing;
@property (nonatomic) BOOL hasConnected;

+ (instancetype)createCall:(VICall *)call uuid:(NSUUID *)uuid isOutgoing:(BOOL)isOutgoing hasConnected:(BOOL)hasConnected;

@end

@interface ACKCallManager : NSObject<CXProviderDelegate, VIClientCallManagerDelegate, VICallDelegate>

@property (weak, atomic) id<CallManagerDelegate> delegate;
@property (nonatomic, strong, nullable) ACKCallWrapper *managedCall;

- (instancetype)initWithClient:(VIClient *)client authService:(ACKAuthService *)authService;
- (void)startOutgoingCallWithContact:(NSString *)contact completion:(void (^)(VICall *_Nullable call, NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
