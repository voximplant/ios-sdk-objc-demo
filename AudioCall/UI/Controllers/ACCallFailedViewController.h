/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ACCallFailedViewController : UIViewController

@property (strong, nonatomic) NSString *failingReason;
@property (strong, nonatomic) NSString *endpointDisplayName;

@end

NS_ASSUME_NONNULL_END
