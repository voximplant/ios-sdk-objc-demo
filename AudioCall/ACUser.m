/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "ACUser.h"

@implementation ACUser

+ (instancetype)userWithUsername:(NSString *)username displayName:(NSString *)displayName {
    ACUser *user = [[ACUser alloc] init];
    user.username = username;
    user.displayName = displayName;
    return user;
}

@end
