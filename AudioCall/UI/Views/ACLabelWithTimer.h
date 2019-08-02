/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import <UIKit/UIKit.h>

@protocol ACTimerDelegate <NSObject>

- (void)updateTime;

@end

@interface ACLabelWithTimer : UILabel

- (void)runTimer;

@property (weak, atomic) IBOutlet id<ACTimerDelegate> delegate;

@end
