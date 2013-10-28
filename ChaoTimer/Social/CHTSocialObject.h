//
//  CHTSocialObject.h
//  ChaoTimer
//
//  Created by Jichao Li on 10/22/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ShareSDK/ShareSDK.h>

@interface CHTSocialObject : NSObject

@property (nonatomic) ShareType shareType;
@property (nonatomic) bool isAuthed;
@property (nonatomic) bool needAuth;

- (void)authWithDelegate:(id<ISSShareViewDelegate>)delegate tableView:(UITableView *)view;
- (void)unAuth;
+ (CHTSocialObject *)initWithType: (ShareType)type;
- (NSString *)toString;
- (UIImage *)getSmallImage;
@end
