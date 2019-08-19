/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "UIHelper.h"
#import <MBProgressHUD.h>
#import "UIExtensions.h"

@implementation UIHelper

+ (void)showProgressWithTitle:(NSString *)title details:(NSString *)details controller:(UIViewController *)viewController {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (UIView *view in viewController.view.subviews) {
            if ([view isKindOfClass:[MBProgressHUD class]]) {
                return;
            }
        }
        MBProgressHUD *progress = [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
        progress.label.text = title;
        progress.detailsLabel.text = details;
    });
    
}

+ (void)hideProgressOnViewController:(UIViewController *)viewController {
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:viewController.view animated:YES];
    });
}

+ (void)showError:(NSString *)error action:(UIAlertAction *_Nullable)action controller:(UIViewController *_Nullable)controller {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *rootViewController = UIApplication.sharedApplication.keyWindow.rootViewController;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:error preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
        
        if (action) {
            [alert addAction:action];
        }
        
        if (controller) {
            [controller presentViewController:alert animated:true completion:nil];
        } else {
            UIViewController *controllerToUse = rootViewController.toppestViewController;
            [controllerToUse presentViewController:alert animated:true completion:nil];
        }
    });
};

@end
