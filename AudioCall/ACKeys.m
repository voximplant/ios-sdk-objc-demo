/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "ACKeys.h"


@interface ACToken ()

@property (strong, nonatomic, readwrite) NSString *key;
@property (strong, nonatomic, readwrite) NSDate *expireDate;

@end


@implementation ACToken

+ (BOOL)supportsSecureCoding {
    return YES;
}

+ (instancetype)tokenWithKey:(NSString *)key expireDate:(NSDate *)date {
    ACToken *token = [[ACToken alloc] init];
    token.key = key;
    token.expireDate = date;
    return token;
}

- (BOOL)isExpired {
    return [[NSDate date] earlierDate:self.expireDate] == self.expireDate;
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    if (self = [super init]) {
        self.key = [aDecoder decodeObjectForKey:@"key"];
        self.expireDate = [aDecoder decodeObjectForKey:@"expireDate"];
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:self.key forKey:@"key"];
    [aCoder encodeObject:self.expireDate forKey:@"expireDate"];
}

@end



@implementation ACKeys

+ (BOOL)supportsSecureCoding {
    return YES;
}

+ (instancetype)keyholderWithAccessToken:(ACToken *)accessKey refreshKey:(ACToken *)refreshKey {
    ACKeys *keys = [[ACKeys alloc] init];
    keys.accessToken = accessKey;
    keys.refreshToken = refreshKey;
    return keys;
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    if (self = [super init]) {
        self.accessToken = [aDecoder decodeObjectForKey:@"accessToken"];
        self.refreshToken = [aDecoder decodeObjectForKey:@"refreshToken"];
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:self.accessToken forKey:@"accessToken"];
    [aCoder encodeObject:self.refreshToken forKey:@"refreshToken"];
}

@end
