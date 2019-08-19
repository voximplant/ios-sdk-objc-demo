/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN


@interface VoxToken : NSObject <NSSecureCoding>

@property (strong, nonatomic, readonly) NSString *token;
@property (strong, nonatomic, readonly) NSDate *expireDate;

+ (instancetype)createToken:(NSString *)token expireDate:(NSDate *)date;

- (BOOL)isExpired;

@end


@interface VoxKeys : NSObject <NSSecureCoding>

@property (strong, nonatomic, nullable)VoxToken *access;
@property (strong, nonatomic, nullable)VoxToken *refresh;

+ (instancetype)keyholderWithAccess:(VoxToken *)access refresh:(VoxToken *)refresh;

@end

NS_ASSUME_NONNULL_END
