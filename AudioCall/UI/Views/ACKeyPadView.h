/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@protocol KeyPadDelegate <NSObject>

- (void)DTMFButtonTouched:(NSString *)symbol;
- (void)keypadDidHide;

@end



@interface ACKeyPadView : UIView

@property (weak, atomic) IBOutlet id<KeyPadDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
