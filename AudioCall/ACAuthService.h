/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "VoxUser.h"
@import VoxImplantSDK;


NS_ASSUME_NONNULL_BEGIN

typedef void(^VoxResult)(NSString *_Nullable userDisplayName, NSError *_Nullable error);

@interface ACAuthService : NSObject

@property (strong, nonatomic, nullable) NSString *loggedInUser;
@property (strong, nonatomic, nullable) NSString *loggedInUserDisplayName;
@property (nonatomic) VIClientState state;

- (instancetype)initWithClient:(VIClient *)client;
- (void)loginWithUser:(NSString *)user password:(NSString *)password result:(VoxResult)completion;
- (void)loginUsingTokenWithCompletion:(VoxResult)completion;
- (NSDate *)possibleToLogin;
- (void)disconnect:(dispatch_block_t)completion;
- (void)logout:(dispatch_block_t)completion;

@end

NS_ASSUME_NONNULL_END
