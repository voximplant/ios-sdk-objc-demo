/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "VoxUser.h"
#import <VoxImplant/VoxImplant.h>


NS_ASSUME_NONNULL_BEGIN

typedef void(^VoxResult)(NSString *_Nullable userDisplayName, NSError *_Nullable error);

@interface ACKAuthService : NSObject

@property (strong, nonatomic, nullable) VoxUser *lastLoggedInUser;
@property (strong, nonatomic, nullable) NSData *pushToken;

- (instancetype)initWithClient:(VIClient *)client;
- (void)loginWithUser:(NSString *)user password:(NSString *)password result:(VoxResult)completion;
- (void)loginUsingTokenWithUser:(NSString *)user completion:(VoxResult)completion;
- (NSDate *)possibleToLogin;
- (void)disconnect:(dispatch_block_t)completion;
- (void)logout:(dispatch_block_t)completion;

@end

NS_ASSUME_NONNULL_END
