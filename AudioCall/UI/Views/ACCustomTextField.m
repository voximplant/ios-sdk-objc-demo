/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "ACCustomTextField.h"

@implementation ACCustomTextField

@dynamic rightSideView;

- (UIView *)rightSideView {
    return super.rightView;
}

- (void)setRightSideView:(UIView *)newValue {
    super.rightView = newValue;
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
    self.layer.shadowColor = UIColor.blackColor.CGColor;
    self.layer.shadowRadius = 15;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowOpacity = 0.03;
    self.rightViewMode = UITextFieldViewModeAlways;
}

#pragma mark - Actions
- (IBAction)nextField:(UITextField *)sender {
    [self becomeFirstResponder];
}

@end
