/*
*  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
*/

#import <UIKit/UIKit.h>
#import "VoxUser.h"

@interface VoxEndpointLabel : UILabel

@property (strong, nonatomic)VoxUser *user;

- (void)updateLabel;

@end
