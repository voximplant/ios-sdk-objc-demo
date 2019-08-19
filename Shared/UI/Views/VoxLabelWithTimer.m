/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "VoxLabelWithTimer.h"

@interface VoxLabelWithTimer ()

@property (strong, nonatomic) NSTimer *timer;

- (NSString *_Nullable)convertTimeToString:(NSTimeInterval)time;

@end

@implementation VoxLabelWithTimer

- (void)runTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                  target:self
                                                selector:@selector(updateTimer)
                                                userInfo:nil
                                                 repeats:YES];
    [self setIsTimerRunning:YES];
}

- (void)updateTimer {
    [self.delegate updateTime];
}

- (void)setTime:(NSTimeInterval)time {
    NSString *text;
    if (time) {
        text = [[self convertTimeToString:time] stringByAppendingString:@" - "];
    } else {
        text = @"";
    }
    self.text = [text stringByAppendingString:@"Call in progress"];
}

- (NSString *_Nullable)convertTimeToString:(NSTimeInterval)time {
    int minutes = (int)time / 60 % 60;
    int seconds = (int)time % 60;
    return [NSString stringWithFormat:@"%02i:%02i",minutes,seconds];
}

- (void)dealloc {
    [self.timer invalidate];
    [self setIsTimerRunning:NO];
}

@end
