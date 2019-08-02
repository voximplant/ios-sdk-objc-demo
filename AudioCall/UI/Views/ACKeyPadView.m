/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "ACKeyPadView.h"

@interface ACKeyPadView ()

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *numberButtons;
@property (strong, nonatomic, readonly) NSString *nibName;
@property (strong, nonatomic) UIView *contentView;

@end

@implementation ACKeyPadView

- (NSString *)nibName {
    return NSStringFromClass([self class]);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        UIView *view = [self loadFromNib];
        view.frame = self.bounds;
        [self addSubview:view];
        self.contentView = view;
    }
    return self;
}

- (UIView *)loadFromNib {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UINib *nib = [UINib nibWithNibName:self.nibName bundle:bundle];
    
    return [nib instantiateWithOwner:self options:nil].firstObject; // as? UIVIEW/
}

- (IBAction)numberTouch:(UIButton *)sender {
    NSString *symbolSentFromDTMF = sender.currentTitle;
    [self.delegate DTMFButtonTouched:symbolSentFromDTMF];
}

- (IBAction)hideTouch:(UIButton *)sender {
    [self setHidden:YES];
    [self.delegate keypadDidHide];
}

@end
