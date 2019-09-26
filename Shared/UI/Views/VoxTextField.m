/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "VoxTextField.h"

@interface VoxTextField ()

@property (nonatomic) UIEdgeInsets padding;

@end

@implementation VoxTextField

@dynamic rightSideView;

- (UIEdgeInsets)padding {
    return UIEdgeInsetsMake(0, 5, 0, 100);
}

- (UIView *)rightSideView {
    return super.rightView;
}

- (void)setRightSideView:(UIView *)newValue {
    super.rightView = newValue;
}

- (NSString *)textWithVoxDomain {
    return [self.text stringByAppendingString:@".voximplant.com"];
}

#pragma mark - Init
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void) setupUI {
    [self setValue:UIColor.darkGrayColor forKeyPath:@"placeholderLabel.textColor"];
    self.layer.shadowColor = UIColor.blackColor.CGColor;
    self.layer.shadowRadius = 15;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowOpacity = 0.03;
    self.layer.masksToBounds = true;
    self.layer.cornerRadius = 8;
    self.layer.borderColor = UIColor.lightGrayColor.CGColor;
    self.layer.borderWidth = 0.3;
    self.rightViewMode = UITextFieldViewModeAlways;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return UIEdgeInsetsInsetRect(bounds, self.padding);
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
     return UIEdgeInsetsInsetRect(bounds, self.padding);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
     return UIEdgeInsetsInsetRect(bounds, self.padding);
}

#pragma mark - Actions
- (IBAction)nextField:(UITextField *)sender {
    [self becomeFirstResponder];
}

@end
