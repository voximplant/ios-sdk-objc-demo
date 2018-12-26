/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VIBranding : NSObject

+ (UIColor *)headerColor;

+ (UIColor *)color;

+ (UIColor *)cancelColor;

+ (CGFloat)minimumHeight;

+ (CGFloat)minimumWidth;

+ (UIFont *)defaultFont;

+ (UIFont *)titleFont;

+ (NSDictionary *)titleTextAttributes;

+ (UIColor *)criticalColor;

+ (UIColor *)errorColor;

+ (UIColor *)warningColor;

+ (UIColor *)infoColor;

@end

@interface UIImage (ImageWithColor)

+ (UIImage *)imageWithColor:(UIColor *)color;

@end

@interface VIButton : UIButton

@property (assign, nonatomic, getter=isFilled) IBInspectable BOOL filled;

@end

@interface VIInputField : UITextField

@end

NS_ASSUME_NONNULL_END
