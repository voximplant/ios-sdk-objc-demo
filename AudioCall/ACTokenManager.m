/*
 *  Copyright (c) 2011-2019, Zingaya, Inc. All rights reserved.
 */

#import "ACTokenManager.h"
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



@implementation ACTokenManager

- (ACKeys *)getKeys {
    if (@available(iOS 11.0, *)) {
        NSError *error;
        NSSet *set = [NSSet setWithArray:@[[ACKeys class], [ACToken class], [NSObject class]]];
        ACKeys *keys = [NSKeyedUnarchiver unarchivedObjectOfClasses:set
                                                           fromData:[[NSUserDefaults standardUserDefaults] objectForKey: [NSUserDefaults keyholderKey]]
                                                              error:&error];
        if ([[keys refreshToken] isExpired]) { return nil; }
        return keys;
    } else {
        ACKeys *keys = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:[NSUserDefaults keyholderKey]]];
        if ([[keys refreshToken] isExpired]) { return nil; }
        return keys;
    }
}

- (void)setKeys:(ACKeys *)keys {
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
