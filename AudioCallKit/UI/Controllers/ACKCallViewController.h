/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import <UIKit/UIKit.h>
#import "VoxKeyPadView.h"
#import <VoxImplant/VoxImplant.h>
#import "VoxApplication.h"
#import <CallKit/CallKit.h>

@interface ACKCallViewController : UIViewController<VIAudioManagerDelegate, KeyPadDelegate, AppLifeCycleDelegate, CXCallObserverDelegate>

@end
