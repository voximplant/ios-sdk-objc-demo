/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "VoxLabelWithTimer.h"

@interface VoxLabelWithTimer ()

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end


@implementation VoxLabelWithTimer

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupDateFormatter];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupDateFormatter];
    }
    return self;
}

- (void)setupDateFormatter {
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.timeZone = [[NSTimeZone alloc] initWithName:@"UTC"];
    self.dateFormatter.dateFormat = @"HH:mm:ss";
}

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

- (NSString *)buildStringTimeToDisplayWithTime:(NSTimeInterval)timeInterval {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSString *formattedDate = [self.dateFormatter stringFromDate:date];
    return [formattedDate hasPrefix:@"00"] ? [formattedDate substringFromIndex:3] : formattedDate;
}

- (void)dealloc {
    [self.timer invalidate];
    [self setIsTimerRunning:NO];
}

@end
