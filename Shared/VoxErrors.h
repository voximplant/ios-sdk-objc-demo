/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSErrorDomain const VoxErrorDomain NS_STRING_ENUM;
FOUNDATION_EXPORT VoxErrorDomain const AudioCallErrorDomain;

typedef NS_ERROR_ENUM(AudioCallErrorDomain, ErrorCode) {
    /**User password is needed for login. */
    ErrorCodeUserPasswordRequired = 5019,
    /**Can't start an outgoing call: couldn't create a VICall instance. */
    ErrorCodeOutgoingCallCreationInternalVoximplant = 5030,
    /**Can't start an outgoing call: CallManager already has a manage call or nil. */
    ErrorCodeOutgoingCallCreationAlreadyManageCall = 5091,
    /**Error encoding object. */
    ErrorCodeErrorEncodingObject = 1023
};

@interface NSError (Errors)

+ (instancetype)errorWithDomain:(NSErrorDomain)domain code:(NSInteger)code reason:(nullable NSString *)reason;
+ (instancetype)errorRequiredPassword;
+ (instancetype)errorCouldntCreateCall;
+ (instancetype)errorAlreadyHasCall;
+ (instancetype)errorEncodingObject;

@end

NS_ASSUME_NONNULL_END
