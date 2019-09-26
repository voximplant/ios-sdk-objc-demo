/*
*  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
*/

#import "ACKAppDelegate.h"
#import "CXExtensions.h"

@implementation CXCall (CallInfo)

- (VICall *)info {
    if ([AppDelegateMacros.sharedCallManager.managedCall.uuid isEqual:self.UUID]) {
        return AppDelegateMacros.sharedCallManager.managedCall.call;
    }
    return nil;
}

@end

@implementation CXProvider (CXExtensions)

- (void)commitTransactionsWithDelegate:(id<CXProviderDelegate>)delegate {
    for (CXTransaction *transaction in self.pendingTransactions) {
        for (CXAction *action in transaction.actions) {
            NSLog(@"CXProvider: %@", action);
            if ([action isKindOfClass:[CXStartCallAction class]]) {
                [delegate provider:self performStartCallAction:(CXStartCallAction *)action];
            } else if ([action isKindOfClass:[CXAnswerCallAction class]]) {
                [delegate provider:self performAnswerCallAction:(CXAnswerCallAction *)action];
            } else if ([action isKindOfClass:[CXEndCallAction class]]) {
                [delegate provider:self performEndCallAction:(CXEndCallAction *)action];
            } else if ([action isKindOfClass:[CXSetHeldCallAction class]]) {
                [delegate provider:self performSetHeldCallAction:(CXSetHeldCallAction *)action];
            } else if ([action isKindOfClass:[CXSetMutedCallAction class]]) {
                [delegate provider:self performSetMutedCallAction:(CXSetMutedCallAction *)action];
            } else if ([action isKindOfClass:[CXSetGroupCallAction class]]) {
                [delegate provider:self performSetGroupCallAction:(CXSetGroupCallAction *)action];
            } else if ([action isKindOfClass:[CXPlayDTMFCallAction class]]) {
                [delegate provider:self performPlayDTMFCallAction:(CXPlayDTMFCallAction *)action];
            } else {
                NSLog(@"Can't apply pendingTransacton %@ of unknown type: %@", action, [action class]);
            }
        }
    }
}

@end
