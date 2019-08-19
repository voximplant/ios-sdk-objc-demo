/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import <UIKit/UIKit.h>
#import "VoxApplication.h"
#import <CallKit/CallKit.h>

@interface ACKMainViewController : UIViewController<AppLifeCycleDelegate, CXCallObserverDelegate>

- (void)reconnect;

@end
