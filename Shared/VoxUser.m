/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "VoxUser.h"

@implementation VoxUser

+ (instancetype)userWithUsername:(NSString *)username displayName:(NSString *)displayName {
    VoxUser *user = [[VoxUser alloc] init];
    user.username = username;
    user.displayName = displayName;
    return user;
}

@end
