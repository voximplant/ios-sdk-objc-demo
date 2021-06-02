/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "QIAppDelegate.h"
#import "QICallViewController.h"
#import "QIIssueCollectionViewCell.h"
#import "VoxBranding.h"
#import "Quality_Issues-Swift.h"

@import VoxImplantSDK;

@interface QICallViewController () <VICallDelegate, VIEndpointDelegate, VIQualityIssueDelegate>

@property(assign, nonatomic) BOOL sendingVideo;
@property(assign, nonatomic) BOOL onHold;
@property(assign, nonatomic) BOOL backCamera;

@end

@implementation QICallViewController

const NSString *myID = @"me";
static NSString *reuseIdentifier = @"QIIssueCollectionViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak QICallViewController *wSelf = self;
    [_participantsVideoView addParticipantWithId:(NSString *)myID name:nil];
    _participantsVideoView.enlargeParticipantHandler = ^(BOOL enlarged) {
        __strong QICallViewController *sSelf = wSelf;
        [sSelf.issuesView setHidden:enlarged];
    };
}

- (void)setCurrentCall:(VICall *)currentCall {
    _currentCall = currentCall;
    [_currentCall addDelegate:self];
    [_currentCall addDelegate:[QIAppDelegate instance].voxManager];
    _currentCall.qualityIssueDelegate = self;
    [self.issuesList reloadData];
}

- (UIColor *)colorForLevel:(VIQualityIssueLevel)level {
    switch (level) {
        case VIQualityIssueLevelCritical:
            return VoxBranding.criticalColor;
        case VIQualityIssueLevelMajor:
            return VoxBranding.errorColor;
        case VIQualityIssueLevelMinor:
            return VoxBranding.warningColor;
        case VIQualityIssueLevelNone:
        default:
            return VoxBranding.infoColor;
    }
}

- (void)appendText:(NSString *)text withLevel:(VIQualityIssueLevel)issueLevel {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIColor *color = [self colorForLevel:issueLevel];

        NSString *entryText = [NSString stringWithFormat:@"%@\n", text];
        NSAttributedString *newEntry = [[NSAttributedString alloc] initWithString:entryText
                                                                       attributes:@{
                                                                               NSForegroundColorAttributeName: color,
                                                                               NSFontAttributeName: [UIFont systemFontOfSize:14],
                                                                       }];

        NSMutableAttributedString *current = self.issuesView.attributedText.mutableCopy;
        [current appendAttributedString:newEntry];
        self.issuesView.attributedText = current;
        [self.issuesList reloadData];
    });
}

- (void)call:(VICall *)call didDetectCodecMismatch:(NSString *)codec issueLevel:(VIQualityIssueLevel)level {
    [self appendText:[NSString stringWithFormat:@"CodecMismatch: %@", codec] withLevel:level];
}

- (void)call:(VICall *)call didDetectHighMediaLatency:(NSTimeInterval)latency issueLevel:(VIQualityIssueLevel)level {
    [self appendText:[NSString stringWithFormat:@"HighMediaLatency: %.0f", latency] withLevel:level];
}

- (void)call:(VICall *)call didDetectIceDisconnected:(VIQualityIssueLevel)level {
    [self appendText:@"IceDisconnected" withLevel:level];
}

- (void)call:(VICall *)call didDetectLocalVideoDegradation:(CGSize)actualSize targetSize:(CGSize)targetSize issueLevel:(VIQualityIssueLevel)level {
    [self appendText:[NSString stringWithFormat:@"LocalVideoDegradation: %@, target: %@", NSStringFromCGSize(actualSize), NSStringFromCGSize(targetSize)] withLevel:level];
}

- (void)call:(VICall *)call didDetectLowBandwidth:(double)actualBitrate targetBitrate:(double)targetBitrate issueLevel:(VIQualityIssueLevel)level {
    [self appendText:[NSString stringWithFormat:@"LowBandwidth: %.0f, target: %.0f", actualBitrate, targetBitrate] withLevel:level];
}

- (void)call:(VICall *)call didDetectNoAudioSignal:(VIQualityIssueLevel)level {
    [self appendText:@"NoAudioSignal" withLevel:level];
}

- (void)call:(VICall *)call didDetectPacketLoss:(double)packetLoss issueLevel:(VIQualityIssueLevel)level {
    [self appendText:[NSString stringWithFormat:@"PacketLoss: %.3f", packetLoss] withLevel:level];
}

- (void)                   call:(VICall *)call
didDetectNoAudioReceiveOnStream:(VIRemoteAudioStream *)audioStream
                   fromEndpoint:(VIEndpoint *)endpoint
                     issueLevel:(VIQualityIssueLevel)level {
  [self appendText:[NSString stringWithFormat:@"NoAudioReceive from: %@", endpoint.userDisplayName ?: endpoint.user]
         withLevel:level];
}

- (void)                   call:(VICall *)call
didDetectNoVideoReceiveOnStream:(VIRemoteVideoStream *)videoStream
                   fromEndpoint:(VIEndpoint *)endpoint
                     issueLevel:(VIQualityIssueLevel)level {
    [self appendText:[NSString stringWithFormat:@"NoVideoReceive from: %@", endpoint.userDisplayName ?: endpoint.user]
           withLevel:level];
    if (level == VIQualityIssueLevelNone) {
        [_participantsVideoView requestRenderingWithParticipantId:endpoint.endpointId
            render:^(UIView *view) {
            if (view) {
                VIVideoRendererView *renderView = [[VIVideoRendererView alloc] initWithContainerView:view];
                [videoStream addRenderer:renderView];
            }
        }];
    } else if (level == VIQualityIssueLevelCritical) {
        [_participantsVideoView stopRenderingWithParticipantId:endpoint.endpointId];
        [videoStream removeAllRenderers];
    }
}

- (void)holdTouched:(UIButton *)sender {
    __weak QICallViewController *weakSelf = self;

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    BOOL onHold = !self.onHold;
    [alertController addAction:[UIAlertAction actionWithTitle:onHold ? @"Hold" : @"Unhold" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.currentCall setHold:onHold completion:^(NSError *error) {
            weakSelf.onHold = onHold;
        }];
    }]];

    BOOL sendingVideo = !self.sendingVideo;
    [alertController addAction:[UIAlertAction actionWithTitle:sendingVideo ? @"Stop video" : @"Start video" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.currentCall setSendVideo:!sendingVideo completion:^(NSError *error) {
            weakSelf.sendingVideo = sendingVideo;
        }];
    }]];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Switch camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [VICameraManager sharedCameraManager].useBackCamera = ![VICameraManager sharedCameraManager].useBackCamera;
    }]];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)hangUpTouched:(UIButton *)sender {
    [_currentCall hangupWithHeaders:nil];
}

- (void)call:(VICall *)call didAddLocalVideoStream:(VIVideoStream *)videoStream {
    [_participantsVideoView requestRenderingWithParticipantId:(NSString *)myID
        render:^(UIView *view) {
        if (view) {
            VIVideoRendererView *renderView = [[VIVideoRendererView alloc] initWithContainerView:view];
            [videoStream addRenderer:renderView];
        }
    }];
}

- (void)call:(VICall *)call didRemoveLocalVideoStream:(VIVideoStream *)videoStream {
    [_participantsVideoView stopRenderingWithParticipantId:(NSString *)myID];
    [videoStream removeAllRenderers];
}

- (void)call:(VICall *)call didAddEndpoint:(VIEndpoint *)endpoint {
    endpoint.delegate = self;
    if (_isConferenceCall && [endpoint.endpointId isEqualToString:call.callId]) {
        return;
    }
    [_participantsVideoView addParticipantWithId:endpoint.endpointId
                                            name:endpoint.userDisplayName ?: endpoint.user];
}

- (void)endpoint:(VIEndpoint *)endpoint didAddRemoteVideoStream:(VIVideoStream *)videoStream {
    if (_isConferenceCall && [endpoint.endpointId isEqualToString:endpoint.call.callId]) {
        return;
    }
    [_participantsVideoView requestRenderingWithParticipantId:endpoint.endpointId
        render:^(UIView *view) {
        if (view) {
            VIVideoRendererView *renderView = [[VIVideoRendererView alloc] initWithContainerView:view];
            [videoStream addRenderer:renderView];
        }
    }];
}

- (void)endpoint:(VIEndpoint *)endpoint didRemoveRemoteVideoStream:(VIVideoStream *)videoStream {
    if (_isConferenceCall && [endpoint.endpointId isEqualToString:endpoint.call.callId]) {
        return;
    }
    [_participantsVideoView stopRenderingWithParticipantId:endpoint.endpointId];
    [videoStream removeAllRenderers];
}

- (void)endpointDidRemove:(VIEndpoint *)endpoint {
    endpoint.delegate = nil;
    if (_isConferenceCall && [endpoint.endpointId isEqualToString:endpoint.call.callId]) {
        return;
    }
    [_participantsVideoView removeParticipantWithId:endpoint.endpointId];
}

- (void)endpointInfoDidUpdate:(VIEndpoint *)endpoint {
    if (_isConferenceCall && [endpoint.endpointId isEqualToString:endpoint.call.callId]) {
        return;
    }
    [_participantsVideoView updateParticipantNameWithId:endpoint.endpointId
                                                   name:endpoint.userDisplayName ?: endpoint.user];
}

- (void)call:(VICall *)call didDisconnectWithHeaders:(NSDictionary *)headers answeredElsewhere:(NSNumber *)answeredElsewhere {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)call:(VICall *)call didFailWithError:(NSError *)error headers:(NSDictionary *)headers {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    _issuesListHeight.constant = 18 * ceilf(_currentCall.qualityIssues.count / 2.f);
    return _currentCall.qualityIssues.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QIIssueCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

    VIQualityIssueType type = _currentCall.qualityIssues[indexPath.row];
    VIQualityIssueLevel level = [_currentCall issueLevelForType:type];

    [cell setIssueType:type level:level];
    cell.issueLevel.textColor = [self colorForLevel:level];

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(floorf(collectionView.frame.size.width / 2.f) - 2, 18);
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (@available(iOS 13.0, *)) { return UIStatusBarStyleDarkContent; }
    else { return UIStatusBarStyleDefault; }
}

@end
