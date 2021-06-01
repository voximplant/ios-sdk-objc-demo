/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import <UIKit/UIKit.h>

@class VICall;
@class ConferenceView;

NS_ASSUME_NONNULL_BEGIN

@interface QICallViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet ConferenceView *participantsVideoView;
@property (strong, nonatomic) IBOutlet UIButton *holdButton;
@property (strong, nonatomic) IBOutlet UIButton *hangUpButton;
@property (strong, nonatomic) IBOutlet UITextView *issuesView;
@property (strong, nonatomic) IBOutlet UICollectionView *issuesList;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *issuesListHeight;

- (IBAction)holdTouched:(UIButton *)sender;
- (IBAction)hangUpTouched:(UIButton *)sender;

@property(strong, nonatomic) VICall *currentCall;
@property(assign, nonatomic) BOOL isConferenceCall;

@end

NS_ASSUME_NONNULL_END
