/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIHelper : NSObject

+ (void)showProgressWithTitle:(NSString *)title details:(NSString *)details controller:(UIViewController *)viewController;
+ (void)hideProgressOnViewController:(UIViewController *)viewController;
+ (void)showError:(NSString *)error action:(UIAlertAction *_Nullable)action controller:(UIViewController *_Nullable)controller;
+ (UIViewController *)topPresentedController:(UIViewController *)controller;

@end

NS_ASSUME_NONNULL_END
