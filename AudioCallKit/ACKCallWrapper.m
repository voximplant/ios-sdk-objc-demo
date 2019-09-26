/*
*  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
*/

#import "ACKCallWrapper.h"

@interface ACKCallWrapper ()

@property (strong, nonatomic, nullable) dispatch_block_t pushProcessingCompletion;
@property (strong, nonatomic, nonnull) NSUUID *uuidOnInit;
@property (strong, nonatomic) VICall *call;

@end

@implementation ACKCallWrapper

- (NSUUID *)uuid {
    if (_call) { return _call.callKitUUID; }
    else { return self.uuidOnInit; }
}

- (void)completePushProcessing {
    if (self.pushProcessingCompletion) {
        [self pushProcessingCompletion];
        self.pushProcessingCompletion = nil;
    }
}

- (void)setCall:(VICall *)call delegate:(id<VICallDelegate>)delegate {
    [self.call removeDelegate:delegate];
    self.call = call;
    [self.call addDelegate:delegate];
}

- (instancetype)initWitUUID:(NSUUID *)uuid isOutgoing:(BOOL)isOutgoing pushProcessingCompletion:(nullable dispatch_block_t)pushProcessingCompletion {
    self = [super init];
    if (self) {
        self.isOutgoing = isOutgoing;
        self.uuidOnInit = uuid;
        self.pushProcessingCompletion = pushProcessingCompletion;
    }
    return self;
}

- (instancetype)initWithUUID:(NSUUID *)uuid isOutgoing:(BOOL)isOutgoing {
    self = [super init];
    if (self) {
        self.isOutgoing = isOutgoing;
        self.uuidOnInit = uuid;
    }
    return self;
}

@end
