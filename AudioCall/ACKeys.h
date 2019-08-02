/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN


@interface ACToken : NSObject <NSSecureCoding>

@property (strong, nonatomic, readonly) NSString *key;
@property (strong, nonatomic, readonly) NSDate *expireDate;

+ (instancetype)tokenWithKey:(NSString *)key expireDate:(NSDate *)date;

- (BOOL)isExpired;

@end


@interface ACKeys : NSObject <NSSecureCoding>

@property (strong, nonatomic, nullable)ACToken *accessToken;
@property (strong, nonatomic, nullable)ACToken *refreshToken;

+ (instancetype)keyholderWithAccessToken:(ACToken *)accessKey refreshKey:(ACToken *)refreshKey;

@end

NS_ASSUME_NONNULL_END
