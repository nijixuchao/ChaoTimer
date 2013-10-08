//
//  CHTSettings.m
//  ChaoTimer
//
//  Created by Jichao Li on 9/19/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import "CHTSettings.h"

#define KEY_FREEZE_TIME @"freezeTime"
#define DEFAULT_FREEZE_TIME 50
#define KEY_CURRENT_SESSION  @"currentSession"
#define DEFAULT_CURRENT_SESSION  @"main session"

@implementation CHTSettings


+ (int) getFreezeTime {
    int freezeTime;
    if ([CHTSettings hasObjectForKey:KEY_FREEZE_TIME]) {
        freezeTime = [CHTSettings getSavedInt:KEY_FREEZE_TIME];
    } else {
        freezeTime = DEFAULT_FREEZE_TIME;
        [CHTSettings saveFreezeTime:freezeTime];
    }
    return freezeTime;
}

+ (void) saveFreezeTime:(int)freezeTime {
    [CHTSettings saveInt:freezeTime forKey:KEY_FREEZE_TIME];
}

+ (NSString *) getCurrentSession {
    NSString *currentSession = DEFAULT_CURRENT_SESSION;
    if([CHTSettings hasObjectForKey:KEY_CURRENT_SESSION]) {
        currentSession = [CHTSettings getSavedString:KEY_CURRENT_SESSION];
    } else {
        currentSession = DEFAULT_CURRENT_SESSION;
        [CHTSettings saveCurrentSession:currentSession];
    }
    return currentSession;
}

+ (void) saveCurrentSession:(NSString *)currentSession{
    [CHTSettings saveString:currentSession forKey:KEY_CURRENT_SESSION];
}

+ (BOOL) getSavedBool:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:key];
}
+ (int) getSavedInt: (NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:key];
}
+ (NSString *) getSavedString: (NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:key];
}
+ (BOOL) hasObjectForKey: (NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:key] != nil) {
        return YES;
    } else {
        return NO;
    }
}

+ (void) saveBool:(BOOL)value forKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:value forKey:key];
    [defaults synchronize];
}

+ (void) saveInt:(int)value forKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:value forKey:key];
    [defaults synchronize];
}
+ (void) saveString:(NSString *)value forKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:value forKey:key];
    [defaults synchronize];
}

@end
