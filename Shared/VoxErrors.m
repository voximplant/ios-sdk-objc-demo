/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "VoxErrors.h"

NSErrorDomain const AudioCallErrorDomain = @"com.voximplant.demos.objc.AudioCall";

@implementation NSError (Errors)

+ (instancetype)errorWithDomain:(NSErrorDomain)domain code:(NSInteger)code reason:(nullable NSString *)reason {
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    NSString *safeReason = reason ?: [NSError reasonForCode:code];
    if (safeReason) {
        userInfo[@"reason"] = safeReason;
        userInfo[NSLocalizedDescriptionKey] = safeReason;
    }
    return [NSError errorWithDomain:domain code:code userInfo:userInfo];
}

+ (instancetype)errorRequiredPassword {
    return [NSError errorWithDomain:AudioCallErrorDomain
                               code:ErrorCodeUserPasswordRequired
                             reason:[NSError reasonForCode:ErrorCodeUserPasswordRequired]];
}

+ (instancetype)errorCouldntCreateCall {
    return [NSError errorWithDomain:AudioCallErrorDomain
                               code:ErrorCodeOutgoingCallCreationInternalVoximplant
                             reason:[NSError reasonForCode:ErrorCodeOutgoingCallCreationInternalVoximplant]];
}

+ (instancetype)errorAlreadyHasCall {
    return [NSError errorWithDomain:AudioCallErrorDomain
                               code:ErrorCodeOutgoingCallCreationAlreadyManageCall
                             reason:[NSError reasonForCode:ErrorCodeOutgoingCallCreationAlreadyManageCall]];
}

+ (instancetype)errorEncodingObject {
    return [NSError errorWithDomain:AudioCallErrorDomain
                               code:ErrorCodeErrorEncodingObject
                             reason:[NSError reasonForCode:ErrorCodeErrorEncodingObject]];
}

+ (NSString *)reasonForCode:(NSInteger)code {
    switch (code) {
        case ErrorCodeUserPasswordRequired:
            return @"User password is needed for login.";
        case ErrorCodeOutgoingCallCreationInternalVoximplant:
            return @"Can't start an outgoing call: couldn't create a VICall instance.";
        case ErrorCodeOutgoingCallCreationAlreadyManageCall:
            return @"Can't start an outgoing call: CallManager already has a manage call or nil.";
            case ErrorCodeErrorEncodingObject:
            return @"Error encoding object.";
        default:
            return [NSString stringWithFormat:@"Error with code: %zd", code];
    }
}

@end


