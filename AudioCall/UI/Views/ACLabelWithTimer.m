/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "ACLabelWithTimer.h"

@interface ACLabelWithTimer ()

@property (strong, nonatomic) NSTimer *timer;

@end

@implementation ACLabelWithTimer

- (void)runTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1
                                             target:self
                                           selector:@selector(updateTimer)
                                           userInfo:nil
                                            repeats:YES];
}

- (void)updateTimer {
    [self.delegate updateTime];
}

- (void)dealloc {
    [self.timer invalidate];
}

@end
