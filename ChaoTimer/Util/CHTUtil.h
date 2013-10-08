//
//  CHTUtil.h
//  ChaoTimer
//
//  Created by Jichao Li on 8/12/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum device {
    DEVICE_PHONE = 0,
    DEVICE_PAD = 1,
} Device;

@interface CHTUtil : NSObject

+ (NSString *)getLocalizedString: (NSString *)str;
+ (NSString *)convertTimeFromMsecondToString: (int)msecond;
+ (Device) getDevice;
+ (NSString *)escapeString: (NSString *)string;
+ (CGFloat) getScreenWidth;
+ (CGFloat) calculateCellHeightWithText:(NSString *)text fontSize:(CGFloat)fontSize cellWidth:(CGFloat)width cellMargin:(CGFloat)margin;
+ (UIImage *)imageWithColor:(UIColor *)color;
@end
