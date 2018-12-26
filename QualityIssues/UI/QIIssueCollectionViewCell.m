/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "QIIssueCollectionViewCell.h"

@interface QIIssueCollectionViewCell ()

@property (strong, nonatomic) NSDictionary<VIQualityIssueType, NSString *> *issueNames;
- (NSString *)descriptionForIssueLevel:(VIQualityIssueLevel)level;

@end

@implementation QIIssueCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    _issueNames = @{
                    VIQualityIssueTypeCodecMismatch: @"Codec mism.",
                    VIQualityIssueTypeLowBandwidth: @"Bandwidth",
                    VIQualityIssueTypePacketLoss: @"Packet loss",
                    VIQualityIssueTypeIceDisconnected: @"ICE discon.",
                    VIQualityIssueTypeLocalVideoDegradation: @"Local video",
                    VIQualityIssueTypeNoAudioSignal: @"No audio",
                    VIQualityIssueTypeHighMediaLatency: @"High latency",
                    };
}

- (NSString *)descriptionForIssueLevel:(VIQualityIssueLevel)level {
    switch (level) {
        case VIQualityIssueLevelCritical: return @"Critical";
        case VIQualityIssueLevelMajor: return @"Major";
        case VIQualityIssueLevelMinor: return @"Minor";
        default: return @"None";
    }
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)setIssueType:(VIQualityIssueType)type level:(VIQualityIssueLevel)level {
    _issueType.text = _issueNames[type];
    _issueLevel.text = [self descriptionForIssueLevel:level];
}

@end
