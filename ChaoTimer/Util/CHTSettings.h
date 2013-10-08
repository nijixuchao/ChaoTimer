//
//  CHTSettings.h
//  ChaoTimer
//
//  Created by Jichao Li on 9/19/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHTSettings : NSObject

+ (int) getFreezeTime;
+ (void) saveFreezeTime:(int)freezeTime;
//+ (NSString *) getCurrentSession;
//+ (void) saveCurrentSession:(NSString *)currentSession;
+ (BOOL) getSavedBool:(NSString *)key;
+ (int) getSavedInt: (NSString *)key;
+ (NSString *) getSavedString: (NSString *)key;
+ (BOOL) hasObjectForKey: (NSString *)key;
+ (void) saveBool:(BOOL)value forKey:(NSString *)key;
+ (void) saveInt:(int)value forKey:(NSString *)key;
+ (void) saveString:(NSString *)value forKey:(NSString *)key;
@end
