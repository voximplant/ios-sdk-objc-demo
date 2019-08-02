/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "ACCustomTextFieldWithButton.h"

@implementation ACCustomTextFieldWithButton

- (CGRect)rightViewRectForBounds:(CGRect)bounds {
    CGRect rightBounds = CGRectMake(bounds.size.width - 70, 3, 67, 38);
    return rightBounds;
}

@end
