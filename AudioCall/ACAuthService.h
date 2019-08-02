/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import "ACUser.h"
#import <VoxImplant/VoxImplant.h>


NS_ASSUME_NONNULL_BEGIN

typedef void(^ACResult)(NSString *_Nullable userDisplayName, NSError *_Nullable error);

@interface ACAuthService : NSObject

@property (strong, nonatomic, nullable) ACUser *lastLoggedInUser;

- (instancetype)initWithClient:(VIClient *)client;
- (void)loginWithUser:(NSString *)user password:(NSString *)password result:(ACResult)completion;
- (void)loginUsingTokenWithUser:(NSString *)user completion:(ACResult)completion;
- (NSDate *)possibleToLogin;
- (void)disconnect:(dispatch_block_t)completion;

@end

NS_ASSUME_NONNULL_END
