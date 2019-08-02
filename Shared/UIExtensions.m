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


