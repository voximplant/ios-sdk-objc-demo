/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "VIBranding.h"

@implementation VIBranding

+ (void)load {
    UINavigationBar.appearance.barStyle = UIBarStyleDefault;
    UINavigationBar.appearance.tintColor = UIColor.whiteColor;
    UINavigationBar.appearance.barTintColor = VIBranding.headerColor;
    UINavigationBar.appearance.titleTextAttributes = @{NSFontAttributeName: VIBranding.titleFont, NSForegroundColorAttributeName: UIColor.whiteColor};

    [UIBarButtonItem.appearance setTitleTextAttributes:VIBranding.titleTextAttributes forState:UIControlStateNormal];
    [UIBarButtonItem.appearance setTitleTextAttributes:VIBranding.titleTextAttributes forState:UIControlStateHighlighted];

    UILabel.appearance.font = VIBranding.defaultFont;
}

+ (UIColor *)headerColor {
    return [UIColor colorWithRed:0.14 green:0.04 blue:0.29 alpha:1.0];
}

+ (UIColor *)color {
    return [UIColor colorWithRed:0.40 green:0.18 blue:1.0 alpha:1.0];
}

+ (UIColor *)cancelColor {
    return [UIColor colorWithRed:0.96 green:0.29 blue:0.37 alpha:1.0];
}

+ (CGFloat)minimumHeight {
    return 40;
}

+ (CGFloat)minimumWidth {
    return 72;
}

+ (UIFont *)defaultFont {
    return [UIFont systemFontOfSize:14.0];
}

+ (UIFont *)titleFont {
    return [UIFont boldSystemFontOfSize:18.0];
}

+ (NSDictionary *)titleTextAttributes {
    return @{
            NSFontAttributeName: VIBranding.defaultFont,
            NSForegroundColorAttributeName: UIColor.whiteColor,
    };
}

+ (UIColor *)criticalColor {
    return [UIColor colorWithRed:0.96 green:0.29 blue:0.37 alpha:1.0];
}

+ (UIColor *)errorColor {
    return [UIColor colorWithRed:0.96 green:0.55 blue:0.29 alpha:1.0];
}

+ (UIColor *)warningColor {
    return [UIColor colorWithRed:0.96 green:0.83 blue:0.01 alpha:1.0];
}

+ (UIColor *)infoColor {
    return [UIColor colorWithRed:0.30 green:0.89 blue:0.02 alpha:1.0];
}

@end

@implementation UIImage (ImageWithColor)

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

@end

@implementation VIButton

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.adjustsImageWhenHighlighted = NO;
    self.adjustsImageWhenDisabled = NO;

    self.titleLabel.font = VIBranding.defaultFont;

    self.clipsToBounds = YES;
    self.layer.cornerRadius = 5;
    self.layer.borderWidth = 1;
    self.layer.borderColor = VIBranding.color.CGColor;

    [self setBackgroundImage:[UIImage imageWithColor:self.isFilled ? VIBranding.color : UIColor.whiteColor] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageWithColor:self.isFilled ? UIColor.whiteColor : VIBranding.color] forState:UIControlStateHighlighted];
    [self setBackgroundImage:[UIImage imageWithColor:self.isFilled ? UIColor.whiteColor : VIBranding.color] forState:UIControlStateSelected];
    [self setBackgroundImage:[UIImage imageWithColor:[self.isFilled ? UIColor.whiteColor : VIBranding.color colorWithAlphaComponent:0.1]] forState:UIControlStateDisabled];

    [self setTitleColor:self.isFilled ? UIColor.whiteColor : VIBranding.color forState:UIControlStateNormal];
    [self setTitleColor:self.isFilled ? VIBranding.color : UIColor.whiteColor forState:UIControlStateHighlighted];
    [self setTitleColor:self.isFilled ? VIBranding.color : UIColor.whiteColor forState:UIControlStateSelected];

    [self setTitle:self.currentTitle.uppercaseString forState:UIControlStateNormal];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1
                                                      constant:VIBranding.minimumHeight]];
}

@end
