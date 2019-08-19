/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "VoxTokenManager.h"
#import "VoxErrors.h"


@implementation UIApplication (UserDefaultsExtensions)

+ (NSString *)userDefaultsDomain {
    return NSBundle.mainBundle.bundleIdentifier;
}

@end

@implementation NSUserDefaults (TokenKeys)

+ (NSString *)keyholderKey {
    return [[[UIApplication userDefaultsDomain] stringByAppendingString:@"."] stringByAppendingString:@"keyholder"];
}

@end



@implementation VoxTokenManager

- (VoxKeys *)getKeys {
    if (@available(iOS 11.0, *)) {
        NSError *error;
        NSSet *set = [NSSet setWithArray:@[[VoxKeys class], [VoxToken class], [NSObject class]]];
        VoxKeys *keys = [NSKeyedUnarchiver unarchivedObjectOfClasses:set
                                                           fromData:[[NSUserDefaults standardUserDefaults] objectForKey: [NSUserDefaults keyholderKey]]
                                                              error:&error];
        if ([[keys refresh] isExpired]) { return nil; }
        return keys;
    } else {
        VoxKeys *keys = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:[NSUserDefaults keyholderKey]]];
        if ([[keys refresh] isExpired]) { return nil; }
        return keys;
    }
}

- (void)setKeys:(VoxKeys *_Nullable)keys {
    if (@available(iOS 11.0, *)) {
        NSError *error;
        NSData *encodedKeys = [NSKeyedArchiver archivedDataWithRootObject:keys
                                                    requiringSecureCoding:YES
                                                                    error:&error];
        [[NSUserDefaults standardUserDefaults] setObject:encodedKeys forKey:[NSUserDefaults keyholderKey]];
    } else {
        NSData *encodedKeys = [NSKeyedArchiver archivedDataWithRootObject:keys];
        [[NSUserDefaults standardUserDefaults] setObject:encodedKeys forKey:[NSUserDefaults keyholderKey]];
    }
}

@end
