/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "ACKeys.h"


@interface ACToken ()

@property (strong, nonatomic, readwrite) NSString *token;
@property (strong, nonatomic, readwrite) NSDate *expireDate;

@end


@implementation ACToken

+ (BOOL)supportsSecureCoding {
    return YES;
}

+ (instancetype)createToken:(NSString *)key expireDate:(NSDate *)date {
    ACToken *token = [[ACToken alloc] init];
    token.token = key;
    token.expireDate = date;
    return token;
}

- (BOOL)isExpired {
    return [[NSDate date] earlierDate:self.expireDate] == self.expireDate;
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    if (self = [super init]) {
        self.token = [aDecoder decodeObjectForKey:@"key"];
        self.expireDate = [aDecoder decodeObjectForKey:@"expireDate"];
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:self.token forKey:@"key"];
    [aCoder encodeObject:self.expireDate forKey:@"expireDate"];
}

@end



@implementation ACKeys

+ (BOOL)supportsSecureCoding {
    return YES;
}

+ (instancetype)keyholderWithAccess:(ACToken *)accessKey refresh:(ACToken *)refreshKey {
    ACKeys *keys = [[ACKeys alloc] init];
    keys.access = accessKey;
    keys.refresh = refreshKey;
    return keys;
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    if (self = [super init]) {
        self.access = [aDecoder decodeObjectForKey:@"accessToken"];
        self.refresh = [aDecoder decodeObjectForKey:@"refreshToken"];
    }
    return self;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:self.access forKey:@"accessToken"];
    [aCoder encodeObject:self.refresh forKey:@"refreshToken"];
}

@end
