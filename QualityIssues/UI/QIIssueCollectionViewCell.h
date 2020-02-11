/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import <UIKit/UIKit.h>

@import VoxImplantSDK;

NS_ASSUME_NONNULL_BEGIN

@interface QIIssueCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UILabel *issueType;
@property (strong, nonatomic) IBOutlet UILabel *issueLevel;

- (void)setIssueType:(VIQualityIssueType)type level:(VIQualityIssueLevel)level;

@end

NS_ASSUME_NONNULL_END
