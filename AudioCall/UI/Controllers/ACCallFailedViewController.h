/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import <UIKit/UIKit.h>
#import "ACCallManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACCallFailedViewController : UIViewController<ACCallManagerDelegate>

@property (strong, nonatomic) NSString *failingReason;
@property (strong, nonatomic) NSString *endpointDisplayName;

@end

NS_ASSUME_NONNULL_END
