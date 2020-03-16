/*
*  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
*/

#import <UIKit/UIKit.h>
#import "UIHelper.h"
#import "VoxPermissionsManager.h"
#import <AVFoundation/AVFoundation.h>

@implementation VoxPermissionsManager

+ (void)checkAudioPermission:(dispatch_block_t)completionIfGranted {
    if ([[AVAudioSession sharedInstance] recordPermission] != AVAudioSessionRecordPermissionGranted) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionIfGranted();
                });
            } else {
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"Settings"
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction * _Nonnull action) {
                    [UIApplication.sharedApplication openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                                     options:[NSDictionary new]
                                           completionHandler:nil];
                }];
                [UIHelper showError:@"Audio permission required" action:action controller:nil];
            }
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            completionIfGranted();
        });
    }
}
@end
