/*
*  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
*/

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VoxPermissionsManager : NSObject

+ (void)checkAudioPermission:(dispatch_block_t)completionIfGranted;

@end

NS_ASSUME_NONNULL_END
