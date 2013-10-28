//
//  CHTSocial.h
//  ChaoTimer
//
//  Created by Jichao Li on 10/20/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ShareSDK/ShareSDK.h>

@class CHTSession;
@interface CHTSocial : NSObject

+ (void) registerShareSDK;
+ (void) share:(UIView *)view delegate:(id<ISSShareViewDelegate>)delegate session:(CHTSession *)session image:(id<ISSCAttachment>)image;
+ (NSMutableArray *)getShareTypeList;
+ (NSMutableArray *)getNotShareTypeList;
+ (void)saveShareTypeList: (NSMutableArray *)shareList notShareList: (NSMutableArray *)notShareList;
@end
