/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import <UIKit/UIKit.h>
#import "VoxUser.h"
#import "ACCallManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACMainViewController : UIViewController<ACCallManagerDelegate>

- (void)reconnect;

@end

NS_ASSUME_NONNULL_END
