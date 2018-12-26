/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>

@import VoxImplant;

NS_ASSUME_NONNULL_BEGIN

@protocol QIVoxClientManagerListener <NSObject>

@optional

- (void)connectionDidClose:(nullable NSError *)error;

- (void)loginDidFailWithError:(NSError *)error;
- (void)loginDidSucceedWithName:(NSString *)displayName;

- (void)incomingCallReceived:(VICall *)call withVideoFlags:(VIVideoFlags *)videoFlags;

@end

@interface QIVoxClientManager : NSObject <VICallDelegate>

- (instancetype)initWithClient:(VIClient *)client;

- (void)addListener:(id<QIVoxClientManagerListener>)listener;
- (void)removeListener:(id<QIVoxClientManagerListener>)listener;

- (void)loginWithUsername:(NSString *)username andPassword:(NSString *)password;
- (void)logout;

@property (strong, nonatomic, readonly) VICall *currentCall;

- (VICall *)createCall:(NSString *)user withVideoFlags:(VIVideoFlags *)videoFlags;

@end

NS_ASSUME_NONNULL_END
