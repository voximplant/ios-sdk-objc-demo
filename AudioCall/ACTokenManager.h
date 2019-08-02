/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import <UIKit/UIKit.h>
#import "ACKeys.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIApplication (UserDefaultsExtensions)

+ (NSString *)userDefaultsDomain;

@end

@interface ACTokenManager : NSObject

- (ACKeys *)getKeys;
- (void)setKeys:(ACKeys *)keys;

@end

NS_ASSUME_NONNULL_END
