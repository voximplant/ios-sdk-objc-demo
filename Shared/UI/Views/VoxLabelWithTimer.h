/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import <UIKit/UIKit.h>

@protocol ACKTimerDelegate <NSObject>

- (void)updateTime;

@end

@interface VoxLabelWithTimer : UILabel

- (void)runTimer;
- (void)setTime:(NSTimeInterval)time;

@property (nonatomic) BOOL isTimerRunning;
@property (weak, atomic) IBOutlet id<ACKTimerDelegate> delegate;

@end
