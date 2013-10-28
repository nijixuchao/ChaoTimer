//
//  CHTSocialObject.m
//  ChaoTimer
//
//  Created by Jichao Li on 10/22/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import "CHTSocialObject.h"
#import "CHTUtil.h"

@implementation CHTSocialObject
@synthesize shareType;
@synthesize isAuthed;
@synthesize needAuth;

- (bool) isAuthed {
    if (!self.needAuth) {
        return false;
    }
    if ([ShareSDK hasAuthorizedWithType:shareType]) {
        return true;
    } else {
        return false;
    }
}

- (bool) needAuth {
    if (self.shareType == ShareTypeSinaWeibo ||
        self.shareType == ShareTypeFacebook ||
        self.shareType == ShareTypeTwitter ||
        self.shareType == ShareTypeRenren) {
        return true;
    } else {
        return false;
    }
}

- (void)authWithDelegate:(id<ISSShareViewDelegate>)delegate tableView:(UITableView *)view{
    NSDictionary *followAccount = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [ShareSDK userFieldWithType:SSUserFieldTypeName
                                                         value:@"你继续吵先生儿"],
                                   SHARE_TYPE_NUMBER(ShareTypeSinaWeibo), nil];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                                scopes:nil powerByHidden:YES followAccounts:followAccount authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:delegate
                                               authManagerViewDelegate:delegate];
    
    [ShareSDK authWithType:self.shareType
                   options:authOptions
                    result:^(SSAuthState state, id<ICMErrorInfo> error) {
                        if (state == SSAuthStateSuccess)
                        {
                            NSLog(@"成功");
                        }
                        else if (state == SSAuthStateFail)
                        {
                            NSLog(@"失败");
                        }
                        [view reloadData];
                    }];
    
}

- (void)unAuth {
    [ShareSDK cancelAuthWithType:self.shareType];
}

+ (CHTSocialObject *)initWithType: (ShareType)type {
    CHTSocialObject *socialObj = [[CHTSocialObject alloc] init];
    socialObj.shareType = type;
    return socialObj;
}

- (NSString *)toString {
    switch (self.shareType) {
        case ShareTypeSinaWeibo:
            return [CHTUtil getLocalizedString:@"weibo"];
        case ShareTypeWeixiSession:
            return [CHTUtil getLocalizedString:@"wxFriend"];
        case ShareTypeWeixiTimeline:
            return [CHTUtil getLocalizedString:@"wxTimeline"];
        case ShareTypeRenren:
            return [CHTUtil getLocalizedString:@"renren"];
        case ShareTypeFacebook:
            return [CHTUtil getLocalizedString:@"facebook"];
        case ShareTypeTwitter:
            return [CHTUtil getLocalizedString:@"twitter"];
        case ShareTypeMail:
            return [CHTUtil getLocalizedString:@"mail"];
        case ShareTypeSMS:
            return [CHTUtil getLocalizedString:@"SMS"];
        case ShareTypeCopy:
            return [CHTUtil getLocalizedString:@"copy"];
        default:
            return @"";
    }
}

- (UIImage *)getSmallImage{
    switch (self.shareType) {
        case ShareTypeSinaWeibo:
            return [UIImage imageNamed:@"weibo_sm.png"];
        case ShareTypeWeixiSession:
            return [UIImage imageNamed:@"weixin_sm.png"];
        case ShareTypeWeixiTimeline:
            return [UIImage imageNamed:@"wxTimeline_sm.png"];
        case ShareTypeRenren:
            return [UIImage imageNamed:@"renren_sm.png"];
        case ShareTypeFacebook:
            return [UIImage imageNamed:@"facebook_sm.png"];
        case ShareTypeTwitter:
            return [UIImage imageNamed:@"twitter_sm.png"];
        case ShareTypeMail:
            return [UIImage imageNamed:@"email_sm.png"];
        case ShareTypeSMS:
            return [UIImage imageNamed:@"sms_sm.png"];
        case ShareTypeCopy:
            return [UIImage imageNamed:@"copy_sm.png"];
        default:
            return [UIImage imageNamed:@"share.png"];
    }

}

@end
