/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "VoxBranding.h"
#import "UIExtensions.h"

@interface UIImage (ImageWithColor)

+ (UIImage *)imageWithColor:(UIColor *)color;

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

@implementation VoxBranding

+ (void)load {
    UINavigationBar.appearance.barStyle = UIBarStyleDefault;
    UINavigationBar.appearance.tintColor = UIColor.whiteColor;
    UINavigationBar.appearance.barTintColor = VoxBranding.headerColor;
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

+ (UIImageView *)logoView {
    UIImage *image = [[UIImage imageNamed:@"Logo"] imageWithInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = image;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    return imageView;
}

@end



@implementation VIButton

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.adjustsImageWhenHighlighted = NO;
    self.adjustsImageWhenDisabled = NO;

    self.clipsToBounds = YES;
    self.layer.cornerRadius = 5;
    self.layer.borderWidth = 1;
    self.layer.borderColor = VoxBranding.color.CGColor;

    [self setBackgroundImage:[UIImage imageWithColor:self.isFilled ? UIColor.whiteColor : VoxBranding.color]
                    forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageWithColor:self.isFilled ? VoxBranding.color : UIColor.whiteColor]
                    forState:UIControlStateHighlighted];
    [self setBackgroundImage:[UIImage imageWithColor:self.isFilled ? VoxBranding.color : UIColor.whiteColor]
                    forState:UIControlStateSelected];
    [self setBackgroundImage:[UIImage imageWithColor:[self.isFilled ? UIColor.whiteColor : VoxBranding.color colorWithAlphaComponent:0.1]]
                    forState:UIControlStateDisabled];

    [self setTitleColor:self.isFilled ? VoxBranding.color : UIColor.whiteColor forState:UIControlStateNormal];
    [self setTitleColor:self.isFilled ? UIColor.whiteColor : VoxBranding.color forState:UIControlStateHighlighted];
    [self setTitleColor:self.isFilled ? UIColor.whiteColor : VoxBranding.color forState:UIControlStateSelected];

    [self setTitle:self.currentTitle.uppercaseString forState:UIControlStateNormal];
}

@end


