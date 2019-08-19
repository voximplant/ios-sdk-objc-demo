/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "UIExtensions.h"


@implementation UIImage (ImageWithInsets)

- (UIImage*)imageWithInsets:(UIEdgeInsets)insets {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.size.width + insets.left + insets.right,
                                                      self.size.height + insets.top + insets.bottom),false, self.scale);
    CGPoint origin = CGPointMake(insets.left, insets.top);
    [self drawAtPoint:origin];
    UIImage *imageWithInsets = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageWithInsets;
}

@end


@implementation UIViewController (HideKeyboardWhenTappedAround)

- (void)hideKeyboardWhenTappedAround {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(dismissKeyboard)];
    tap.cancelsTouchesInView = false;
    [self.view addGestureRecognizer: tap];
}

- (void)dismissKeyboard {
    [self.view endEditing:true];
}

@end

@implementation UIViewController (ToppestViewController)

- (UIViewController *)topPresentedController {
    UIViewController *presentedViewController = self.presentedViewController;
    if (presentedViewController) {
        return presentedViewController.topPresentedController;
    } else {
        return self;
    }
}

- (UIViewController *)toppestViewController {
    if ([self isKindOfClass:[UINavigationController class]]) {
        UINavigationController *typeCastedNavigationViewController = (UINavigationController *)self;
        UIViewController *navigationsTopViewController = typeCastedNavigationViewController.topViewController;
        if (navigationsTopViewController) {
            return [navigationsTopViewController topPresentedController];
        } else {
            return self; // no children
        }
    } else if ([self isKindOfClass: [UITabBarController class]]) {
        UITabBarController *typeCastedTabBarController = (UITabBarController *)self;
        UIViewController *tabBarSelectedController = typeCastedTabBarController.selectedViewController;
        if (tabBarSelectedController) {
            return tabBarSelectedController;
        } else {
            return self; // no children
        }
    } else {
        // other container's view controller
        UIViewController *firstChild = self.childViewControllers.firstObject;
        if (firstChild) {
            return firstChild.topPresentedController;
        } else {
            return self.topPresentedController;
        }
    }
}

@end


