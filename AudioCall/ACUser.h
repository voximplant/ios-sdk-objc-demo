/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ACUser : NSObject

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *displayName;

+ (instancetype)userWithUsername:(NSString *)username displayName:(NSString *)displayName;

@end

NS_ASSUME_NONNULL_END
