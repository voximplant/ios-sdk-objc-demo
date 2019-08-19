/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface VoxBranding : NSObject

+ (UIColor *)headerColor;

+ (UIColor *)color;

+ (UIColor *)cancelColor;

+ (CGFloat)minimumHeight;

+ (CGFloat)minimumWidth;

+ (UIColor *)criticalColor;

+ (UIColor *)errorColor;

+ (UIColor *)warningColor;

+ (UIColor *)infoColor;

+ (UIImageView *)logoView;

@end


@interface VIButton : UIButton

@property (assign, nonatomic, getter=isFilled) IBInspectable BOOL filled;

@end

NS_ASSUME_NONNULL_END
