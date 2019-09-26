/*
*  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
*/

#import <CallKit/CallKit.h>
@import VoxImplant;

NS_ASSUME_NONNULL_BEGIN

@interface CXCall (CallInfo)

@property (strong, nonatomic, nullable, readonly)VICall *info;

@end


@interface CXProvider (CXExtensions)

- (void)commitTransactionsWithDelegate:(id<CXProviderDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
