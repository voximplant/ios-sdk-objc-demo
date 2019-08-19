/*
*  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
*/

#import "VoxEndpointLabel.h"

@implementation VoxEndpointLabel

- (void)setUser:(VoxUser *)user {
    if (user) {
        [self setText:user.displayName];
    } else {
        [self setText:@"Calling..."];
    }
    _user = user;
}

- (void)updateLabel {
    if (self.user) {
        [self setText:self.user.displayName];
    } else {
        [self setText:@"Calling..."];
    }
}
@end
