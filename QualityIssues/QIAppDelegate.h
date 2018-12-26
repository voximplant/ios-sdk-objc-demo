/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import <UIKit/UIKit.h>
#import "QIVoxClientManager.h"

@interface QIAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic, readonly) QIVoxClientManager *voxManager;

+ (QIAppDelegate *)instance;

- (void)showError:(NSError *)error;

@end

