//
//  CHTUtil.m
//  ChaoTimer
//
//  Created by Jichao Li on 8/12/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import "CHTUtil.h"

@implementation CHTUtil

+ (NSString *)getLocalizedString: (NSString *)str{
    return NSLocalizedString(str, NULL);
}

+ (NSString *)convertTimeFromMsecondToString: (int)msecond {
    NSString *outputTimeString;
    if (msecond < 1000) {
        outputTimeString = [NSString stringWithFormat:@"0.%03d", msecond];
    } else if (msecond < 60000) {
        int second = msecond * 0.001;
        int msec = msecond % 1000;
        outputTimeString = [NSString stringWithFormat:@"%d.%03d", second, msec];
    } else if (msecond < 3600000) {
        int minute = msecond / 60000;
        int second = (msecond % 60000)/1000;
        int msec = msecond % 1000;
        outputTimeString = [NSString stringWithFormat:@"%d:%02d.%03d", minute, second, msec];
    } else {
        int hour = msecond / 3600000;
        int minute = (msecond % 360000) / 60000;
        int second = (msecond % 60000) / 1000;
        int msec = msecond % 1000;
        outputTimeString = [NSString stringWithFormat:@"%d:%02d:%02d.%03d", hour, minute, second, msec];
    }
    return outputTimeString;
}

+ (Device) getDevice {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return DEVICE_PHONE;
    } else {
        return DEVICE_PAD;
    }
}

+ (NSString *)escapeString: (NSString *)string {
    NSString *fileName = [string copy];
    fileName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"slash"];
    return fileName;
}

+ (CGFloat) getScreenWidth {
    CGFloat screenWidth;
    if ([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortrait || [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortraitUpsideDown){
        screenWidth = [UIScreen mainScreen].applicationFrame.size.width;
    }
    else{
        screenWidth = [UIScreen mainScreen].applicationFrame.size.height;
    }
    return screenWidth;
}

+ (CGFloat) calculateCellHeightWithText:(NSString *)text fontSize:(CGFloat)fontSize cellWidth:(CGFloat)width cellMargin:(CGFloat)margin {
    // Get a CGSize for the width and, effectively, unlimited height
    CGSize constraint = CGSizeMake(width - (margin * 2), 20000.0f);
    // Get the size of the text given the CGSize we just made as a constraint
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    // Get the height of our measurement, with a minimum of 44 (standard cell size)
    CGFloat height = MAX(size.height, 44.0f);
    // return the height, with a bit of extra padding in
    return height+ (margin* 2);
}

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 30.0f, 30.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
