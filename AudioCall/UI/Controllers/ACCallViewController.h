/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import <UIKit/UIKit.h>
#import "ACKeyPadView.h"
#import <VoxImplant/VoxImplant.h>

NS_ASSUME_NONNULL_BEGIN

@interface ACCallViewController : UIViewController<VICallDelegate, VIAudioManagerDelegate, KeyPadDelegate>

@property (strong, nonatomic) NSString *endpointUsername;

@end

NS_ASSUME_NONNULL_END
