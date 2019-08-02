/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import <UIKit/UIKit.h>
#import "ACUser.h"
#import "ACCallManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACMainViewController : UIViewController<CallManagerDelegate>

- (void)reconnect;

@end

NS_ASSUME_NONNULL_END
