/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN


@interface ACToken : NSObject <NSSecureCoding>

@property (strong, nonatomic, readonly) NSString *token;
@property (strong, nonatomic, readonly) NSDate *expireDate;

+ (instancetype)createToken:(NSString *)token expireDate:(NSDate *)date;

- (BOOL)isExpired;

@end


@interface ACKeys : NSObject <NSSecureCoding>

@property (strong, nonatomic, nullable)ACToken *access;
@property (strong, nonatomic, nullable)ACToken *refresh;

+ (instancetype)keyholderWithAccess:(ACToken *)access refresh:(ACToken *)refresh;

@end

NS_ASSUME_NONNULL_END
