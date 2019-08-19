/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import <UIKit/UIKit.h>
#import "VoxKeys.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIApplication (UserDefaultsExtensions)

+ (NSString *)userDefaultsDomain;

@end

@interface VoxTokenManager : NSObject

- (VoxKeys *)getKeys;
- (void)setKeys:(VoxKeys *_Nullable)keys;

@end

NS_ASSUME_NONNULL_END
