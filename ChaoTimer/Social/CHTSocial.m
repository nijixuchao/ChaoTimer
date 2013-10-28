//
//  CHTSocial.m
//  ChaoTimer
//
//  Created by Jichao Li on 10/20/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import "CHTSocial.h"
#import "CHTUtil.h"
#import "CHTSettings.h"
#import "CHTSession.h"
#import "CHTScramble.h"
#import "WXApi.h"
#import <RennSDK/RennSDK.h>

#define shareSdkAppKey @"abffe687d36"
#define weiboAppKey @"3485861470"
#define weiboAppSecret @"84628316a02f82a8a26090300b6c5414"
#define fbAppKey @"325743574177915"
#define fbAppSecret @"4be20a4afe82b03fd136d0636adf2ddf"
#define wxAppId @"wx189ba4a1146a88bf"
#define wxAppKey @"f50c86e7887a7b62e5efbc600d0ed4ca"
#define renrenAppId @"201845"
#define renrenAppKey @"406457ad9904400eaf76e92958dd9658"
#define renrenAppSecret @"8923341e62814acfb37dd54ab99c1f30"
#define twitterKey @"U1a1KkshI2KsAK03DOvU4Q"
#define twitterSecret @"XhoYw6w014RMvCaFDb7EIP38F5EJUtVPY9ZMxOfI"

@interface CHTUtil()

@end

@implementation CHTSocial

+ (void) registerShareSDK
{
    [ShareSDK registerApp:shareSdkAppKey];
    [ShareSDK connectSinaWeiboWithAppKey:weiboAppKey
                               appSecret:weiboAppSecret
                             redirectUri:@"http://"];
    [ShareSDK connectFacebookWithAppKey:fbAppKey
                              appSecret:fbAppSecret];
    [ShareSDK connectTwitterWithConsumerKey:twitterKey
                             consumerSecret:twitterSecret
                                redirectUri:@"http://twitter.com"];
    [ShareSDK connectWeChatWithAppId:wxAppId
                           wechatCls:[WXApi class]];
    [ShareSDK connectRenRenWithAppId:renrenAppId appKey:renrenAppKey appSecret:renrenAppSecret renrenClientClass:[RennClient class]];
}

+ (void) share:(UIView *)view delegate:(id<ISSShareViewDelegate>)delegate session:(CHTSession *)session image:(id<ISSCAttachment>)image
{
    id<ISSContainer> container = [ShareSDK container];
    [container setIPadContainerWithView:view
                            arrowDirect:UIPopoverArrowDirectionUp];
    
    id<ISSContent> publishContent = [ShareSDK content:@"ChaoTimer"
                                       defaultContent:@"ChaoTimer"
                                                image:image
                                                title:@"ChaoTimer"
                                                  url:@"http://t.cn/zWbXPmG"
                                          description:@"From ChaoTimer"
                                            mediaType:SSPublishContentMediaTypeNews];
    
    NSDictionary *followAccount = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [ShareSDK userFieldWithType:SSUserFieldTypeName
                                                         value:@"你继续吵先生儿"],
                                   SHARE_TYPE_NUMBER(ShareTypeSinaWeibo), nil];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                                scopes:nil
                                                         powerByHidden:YES
                                                        followAccounts:followAccount
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:delegate
                                               authManagerViewDelegate:delegate];
    
    
    id<ISSShareOptions> shareOptions = [ShareSDK simpleShareOptionsWithTitle:[CHTUtil getLocalizedString:@"share title"] shareViewDelegate:delegate];
    
    NSArray *shareList = [CHTSocial convertToShareItemListFromShareTypeList:[CHTSocial getShareTypeList] withContainer:container authOptions:authOptions shareOptions:shareOptions session:session image:image];
    
    [ShareSDK showShareActionSheet:container
                         shareList:shareList
                           content:publishContent
                     statusBarTips:YES
                       authOptions:authOptions
                      shareOptions:shareOptions
                            result:^(ShareType type, SSPublishContentState state, id<ISSStatusInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSPublishContentStateSuccess)
                                {
                                    NSLog(@"分享成功");
                                }
                                else if (state == SSPublishContentStateFail)
                                {
                                    NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
                                }
                            }];
}

+ (NSMutableArray *)getShareTypeList {
    if ([CHTSettings hasObjectForKey:@"shareList"]) {
        return [(NSArray *)[CHTSettings getSavedObject:@"shareList"] mutableCopy];
    } else {
        if ([[CHTUtil getLocalizedString:@"language"] isEqualToString:@"Chinese"]) {
            return [NSMutableArray arrayWithObjects:
                    [NSNumber numberWithInt:ShareTypeSinaWeibo],
                    [NSNumber numberWithInt:ShareTypeRenren],
                    [NSNumber numberWithInt:ShareTypeWeixiSession],
                    [NSNumber numberWithInt:ShareTypeWeixiTimeline],
                    [NSNumber numberWithInt:ShareTypeCopy],
                    [NSNumber numberWithInt:ShareTypeMail],
                    [NSNumber numberWithInt:ShareTypeSMS],
                    nil];
        } else {
            return [NSMutableArray arrayWithObjects:
                    [NSNumber numberWithInt:ShareTypeFacebook],
                    [NSNumber numberWithInt:ShareTypeTwitter],
                    [NSNumber numberWithInt:ShareTypeCopy],
                    [NSNumber numberWithInt:ShareTypeMail],
                    [NSNumber numberWithInt:ShareTypeSMS],
                    nil];
        }
    }
}

+ (NSMutableArray *)getNotShareTypeList {
    if ([CHTSettings hasObjectForKey:@"notShareList"]) {
        return [(NSArray *)[CHTSettings getSavedObject:@"notShareList"] mutableCopy];
    } else {
        if ([[CHTUtil getLocalizedString:@"language"] isEqualToString:@"Chinese"]) {
            return [NSMutableArray arrayWithObjects:
                    [NSNumber numberWithInt:ShareTypeFacebook],
                    [NSNumber numberWithInt:ShareTypeTwitter],
                    nil];
        } else {
            return [NSMutableArray arrayWithObjects:
                    [NSNumber numberWithInt:ShareTypeSinaWeibo],
                    [NSNumber numberWithInt:ShareTypeRenren],
                    [NSNumber numberWithInt:ShareTypeWeixiSession],
                    [NSNumber numberWithInt:ShareTypeWeixiTimeline],
                    
                    nil];
        }
    }
}

+ (void)saveShareTypeList: (NSMutableArray *)shareList notShareList: (NSMutableArray *)notShareList {
    [CHTSettings saveObject:shareList forKey:@"shareList"];
    [CHTSettings saveObject:notShareList forKey:@"notShareList"];
}

+ (NSArray *)convertToShareItemListFromShareTypeList: (NSMutableArray *)shareTypeList withContainer:(id<ISSContainer>) container authOptions:(id<ISSAuthOptions>) authOptions shareOptions:(id<ISSShareOptions>) shareOptions session:(CHTSession *)session image:(id<ISSCAttachment>)image {
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:shareTypeList.count];
    NSString *avg = [[session sessionAvg] toString];
    NSString *best = [[session bestSolve] toString];
    NSString *best5 = [[session bestAvgOf:5] toString];
    NSString *best12 = [[session bestAvgOf:12] toString];
    NSString *best100 = [[session bestAvgOf:100] toString];
    
    for (NSNumber *type in shareTypeList) {
        NSLog(@"type: %d", [type intValue]);
        [list addObject:[self getShareSheetItemByType:[type intValue] container:container authOptions:authOptions shareOptions:shareOptions session:session image:image avg:avg best:best best5:best5 best12:best12 best100:best100]];
    }
    
    switch (shareTypeList.count) {
        case 0:
            return [ShareSDK getShareListWithType:ShareTypeSinaWeibo, nil];
            break;
        case 1:
            return [ShareSDK customShareListWithType:
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:0],
                    nil];
            break;
        case 2:
            return [ShareSDK customShareListWithType:
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:0],
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:1],
                    nil];
            break;
        case 3:
            return [ShareSDK customShareListWithType:
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:0],
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:1],
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:2],
                    nil];
            break;
        case 4:
            return [ShareSDK customShareListWithType:
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:0],
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:1],
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:2],
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:3],
                    nil];
            break;
        case 5:
            return [ShareSDK customShareListWithType:
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:0],
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:1],
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:2],
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:3],
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:4],
                    nil];
            break;
        case 6:
            return [ShareSDK customShareListWithType:
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:0],
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:1],
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:2],
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:3],
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:4],
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:5],
                    nil];
            break;
        case 7:
            return [ShareSDK customShareListWithType:
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:0],
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:1],
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:2],
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:3],
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:4],
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:5],
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:6],
                    nil];
            break;
        case 8:
            return [ShareSDK customShareListWithType:
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:0],
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:1],
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:2],
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:3],
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:4],
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:5],
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:6],
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:7],
                    nil];
            break;
        case 9:
            return [ShareSDK customShareListWithType:
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:0],
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:1],
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:2],
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:3],
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:4],
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:5],
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:6],
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:7],
                    (id<ISSShareActionSheetItem>)[list objectAtIndex:8],
                    nil];
            break;
        default:
            return [[NSMutableArray alloc] init];
    }
}


+ (id<ISSShareActionSheetItem>) getShareSheetItemByType: (ShareType)type container:(id<ISSContainer>) container authOptions:(id<ISSAuthOptions>) authOptions shareOptions:(id<ISSShareOptions>) shareOptions session:(CHTSession *)session image:(id<ISSCAttachment>)image  avg:(NSString *)avg best:(NSString *)best best5:(NSString *)best5 best12:(NSString *)best12 best100:(NSString *)best100
{
    NSLog(@"getpublishContent");
    [self getShareStringOfSession:session byType:type avg:avg best:best best5:best5 best12:best12 best100:best100];
    
    id<ISSContent> publishContent = nil;
    
    
    if (type == ShareTypeWeixiTimeline || type == ShareTypeWeixiSession) {
        publishContent = [ShareSDK content:[self getShareStringOfSession:session byType:type avg:avg best:best best5:best5 best12:best12 best100:best100]
                            defaultContent:@"ChaoTimer"
                                     image:image
                                     title:[ShareSDK getClientNameWithType:type]
                                       url:@"http://t.cn/zWbXPmG"
                               description:@"From ChaoTimer"
                                 mediaType:SSPublishContentMediaTypeText];
    } else if(type == ShareTypeRenren) {
        publishContent = [ShareSDK content:[self getShareStringOfSession:session byType:type avg:avg best:best best5:best5 best12:best12 best100:best100]
                            defaultContent:@"ChaoTimer"
                                     image:image
                                     title:@"ChaoTimer"
                                       url:@"http://t.cn/zWbXPmG"
                               description:@"From ChaoTimer"
                                 mediaType:SSPublishContentMediaTypeText];
    } else if(type == ShareTypeCopy) {
        publishContent = [ShareSDK content:[self getShareStringOfSession:session byType:type avg:avg best:best best5:best5 best12:best12 best100:best100]
                            defaultContent:@"ChaoTimer"
                                     image:nil
                                     title:nil
                                       url:nil
                               description:nil
                                 mediaType:SSPublishContentMediaTypeText];
    }
    else {
       publishContent = [ShareSDK content:[self getShareStringOfSession:session byType:type avg:avg best:best best5:best5 best12:best12 best100:best100]
             defaultContent:@"ChaoTimer"
                      image:image
                      title:[ShareSDK getClientNameWithType:type]
                        url:@"http://t.cn/zWbXPmG"
                description:@"From ChaoTimer"
                  mediaType:SSPublishContentMediaTypeNews];
    }
    
    NSLog(@"get sharesheetitem");
    id<ISSShareActionSheetItem> item = [ShareSDK shareActionSheetItemWithTitle:[ShareSDK getClientNameWithType:type]
                                                                          icon:[ShareSDK getClientIconWithType:type]
                                                                  clickHandler:^{
                                                                      [ShareSDK showShareViewWithType:type
                                                                                            container:container
                                                                                              content:publishContent
                                                                                        statusBarTips:YES
                                                                                          authOptions:authOptions
                                                                                         shareOptions:shareOptions
                                                                                               result:^(ShareType type, SSPublishContentState state, id<ISSStatusInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                                                                                   if (state == SSPublishContentStateSuccess)
                                                                                                   {
                                                                                                       NSLog(@"分享成功");
                                                                                                   }
                                                                                                   else if (state == SSPublishContentStateFail)
                                                                                                   {
                                                                                                       NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
                                                                                                   }
                                                                                               }];
                                                                  }];
    return item;
    
}

+ (NSString *) getShareStringOfSession: (CHTSession *)session byType:(ShareType)type avg:(NSString *)avg best:(NSString *)best best5:(NSString *)best5 best12:(NSString *)best12 best100:(NSString *)best100{
    NSString *textToShare = @"";
    NSString *scrambleType = @"";
    int num = session.numberOfSolves;
    switch (type) {
        case ShareTypeSinaWeibo:
        case ShareTypeWeixiSession:
        case ShareTypeWeixiTimeline:
        {
            scrambleType = [CHTScramble getScrambleTypeStringByType:session.currentType language:1];
            if (num == 0) {
                textToShare = [NSString stringWithFormat:@"我正在用#ChaoTimer#进行%@测速，你也来试试？http://t.cn/zWbXPmG", scrambleType];
            } else if (num < 3) {
                textToShare = [NSString stringWithFormat:@"我刚刚用#ChaoTimer#完成了%d次%@测速，最快单次：%@，你也来试试？http://t.cn/zWbXPmG", num, scrambleType, best];
            } else if (num < 5) {
                textToShare = [NSString stringWithFormat:@"我刚刚用#ChaoTimer#完成了%d次%@测速，平均：%@，最快单次：%@，你也来试试？http://t.cn/zWbXPmG", num, scrambleType, avg, best];
            } else if (num < 12) {
                textToShare = [NSString stringWithFormat:@"我刚刚用#ChaoTimer#完成了%d次%@测速，平均：%@，最快单次：%@，最快五次：%@，你也来试试？http://t.cn/zWbXPmG", num, scrambleType, avg, best, best5];
            } else if (num < 100) {
                textToShare = [NSString stringWithFormat:@"我刚刚用#ChaoTimer#完成了%d次%@测速，平均：%@，最快单次：%@，最快五次：%@，最快12次：%@，你也来试试？http://t.cn/zWbXPmG", num, scrambleType, avg, best, best5, best12];
            } else {
                textToShare = [NSString stringWithFormat:@"我刚刚用#ChaoTimer#完成了%d次%@测速，平均：%@，最快单次：%@，最快五次：%@，最快12次：%@，最快100次：%@，你也来试试？http://t.cn/zWbXPmG", num, scrambleType, avg, best, best5, best12, best100];
            }
        }
            break;
        case ShareTypeRenren:
        {
            scrambleType = [CHTScramble getScrambleTypeStringByType:session.currentType language:1];
            if (num == 0) {
                textToShare = [NSString stringWithFormat:@"我正在用#ChaoTimer#进行%@测速，你也来试试？", scrambleType];
            } else if (num < 3) {
                textToShare = [NSString stringWithFormat:@"我刚刚用#ChaoTimer#完成了%d次%@测速，最快单次：%@，你也来试试？", num, scrambleType, best];
            } else if (num < 5) {
                textToShare = [NSString stringWithFormat:@"我刚刚用#ChaoTimer#完成了%d次%@测速，平均：%@，最快单次：%@，你也来试试？", num, scrambleType, avg, best];
            } else if (num < 12) {
                textToShare = [NSString stringWithFormat:@"我刚刚用#ChaoTimer#完成了%d次%@测速，平均：%@，最快单次：%@，最快五次：%@，你也来试试？", num, scrambleType, avg, best, best5];
            } else if (num < 100) {
                textToShare = [NSString stringWithFormat:@"我刚刚用#ChaoTimer#完成了%d次%@测速，平均：%@，最快单次：%@，最快五次：%@，最快12次：%@，你也来试试？", num, scrambleType, avg, best, best5, best12];
            } else {
                textToShare = [NSString stringWithFormat:@"我刚刚用#ChaoTimer#完成了%d次%@测速，平均：%@，最快单次：%@，最快五次：%@，最快12次：%@，最快100次：%@，你也来试试？", num, scrambleType, avg, best, best5, best12, best100];
            }
        }

            break;
        case ShareTypeFacebook:
        {
            scrambleType = [CHTScramble getScrambleTypeStringByType:session.currentType language:0];
            if (num == 0) {
                textToShare = [NSString stringWithFormat:@"I'm using ChaoTimer for my speedcubing, are you wanna try？"];
            } else if (num == 1) {
                textToShare = [NSString stringWithFormat:@"I have just finished %d time %@ solve using ChaoTimer, best time: %@, do you wanna try?", num, scrambleType, best];
            } else if (num < 3) {
                textToShare = [NSString stringWithFormat:@"I have just finished %d times %@ solve using ChaoTimer, best time: %@, are you wanna try?", num, scrambleType, best];
            } else if (num < 5) {
                textToShare = [NSString stringWithFormat:@"I have just finished %d times %@ solves using ChaoTimer, average: %@, best time: %@, are you wanna try?", num, scrambleType, avg, best];
            } else if (num < 12) {
                textToShare = [NSString stringWithFormat:@"I have just finished %d times %@ solves using ChaoTimer, average: %@, best time: %@, best avg5: %@, are you wanna try?", num, scrambleType, avg, best, best5];
            } else if (num < 100) {
                textToShare = [NSString stringWithFormat:@"I have just finished %d times %@ solves using ChaoTimer, average: %@, best time: %@, best avg5: %@, best avg12: %@, are you wanna try?", num, scrambleType, avg, best, best5, best12];
            } else {
                textToShare = [NSString stringWithFormat:@"I have just finished %d times %@ solves using ChaoTimer, average: %@, best time: %@, best avg5: %@, best avg12: %@, best avg100: %@, are you wanna try?", num, scrambleType, avg, best, best5, best12, best100];
            }
        }
            break;
        case ShareTypeTwitter:
        {
            scrambleType = [CHTScramble getScrambleTypeStringByType:session.currentType language:0];
            if (num == 0) {
                textToShare = [NSString stringWithFormat:@"I'm using #ChaoTimer for my speedcubing, are you wanna try？"];
            } else if (num == 1) {
                textToShare = [NSString stringWithFormat:@"%@ solve: %@. via #ChaoTimer", scrambleType, best];
            } else if (num < 3) {
                textToShare = [NSString stringWithFormat:@" %d times %@, best time: %@. via #ChaoTimer", num, scrambleType, best];
            } else if (num < 5) {
                textToShare = [NSString stringWithFormat:@"%d times %@, avg: %@, best time: %@. via #ChaoTimer", num, scrambleType, avg, best];
            } else if (num < 12) {
                textToShare = [NSString stringWithFormat:@"%d times %@, avg: %@, best: %@, best avg5: %@. via #ChaoTimer", num, scrambleType, avg, best, best5];
            } else if (num < 100) {
                textToShare = [NSString stringWithFormat:@"%d times %@, avg: %@, best: %@, best avg5: %@, best avg12: %@. via #ChaoTimer", num, scrambleType, avg, best, best5, best12];
            } else {
                textToShare = [NSString stringWithFormat:@"%d times %@, avg: %@, best: %@, best avg5: %@, best avg12: %@, best avg100: %@. via #ChaoTimer", num, scrambleType, avg, best, best5, best12, best100];
            }
        }
            break;
        case ShareTypeSMS:
        case ShareTypeMail:
            if ([[CHTUtil getLocalizedString:@"language"] isEqualToString:@"Chinese"]) {
                scrambleType = [CHTScramble getScrambleTypeStringByType:session.currentType language:1];
                if (num == 0) {
                    textToShare = [NSString stringWithFormat:@"我正在用#ChaoTimer#进行%@测速，你也来试试？http://t.cn/zWbXPmG", scrambleType];
                } else if (num < 3) {
                    textToShare = [NSString stringWithFormat:@"我刚刚用#ChaoTimer#完成了%d次%@测速，最快单次：%@，你也来试试？http://t.cn/zWbXPmG", num, scrambleType, best];
                } else if (num < 5) {
                    textToShare = [NSString stringWithFormat:@"我刚刚用#ChaoTimer#完成了%d次%@测速，平均：%@，最快单次：%@，你也来试试？http://t.cn/zWbXPmG", num, scrambleType, avg, best];
                } else if (num < 12) {
                    textToShare = [NSString stringWithFormat:@"我刚刚用#ChaoTimer#完成了%d次%@测速，平均：%@，最快单次：%@，最快五次：%@，你也来试试？http://t.cn/zWbXPmG", num, scrambleType, avg, best, best5];
                } else if (num < 100) {
                    textToShare = [NSString stringWithFormat:@"我刚刚用#ChaoTimer#完成了%d次%@测速，平均：%@，最快单次：%@，最快五次：%@，最快12次：%@，你也来试试？http://t.cn/zWbXPmG", num, scrambleType, avg, best, best5, best12];
                } else {
                    textToShare = [NSString stringWithFormat:@"我刚刚用#ChaoTimer#完成了%d次%@测速，平均：%@，最快单次：%@，最快五次：%@，最快12次：%@，最快100次：%@，你也来试试？http://t.cn/zWbXPmG", num, scrambleType, avg, best, best5, best12, best100];
                }
            } else {
                scrambleType = [CHTScramble getScrambleTypeStringByType:session.currentType language:0];
                if (num == 0) {
                    textToShare = [NSString stringWithFormat:@"I'm using ChaoTimer for my speedcubing, are you wanna try？"];
                } else if (num < 3) {
                    textToShare = [NSString stringWithFormat:@"I have just finished %d time %@ solve using ChaoTimer, best time: %@, are you wanna try?", num, scrambleType, best];
                } else if (num < 5) {
                    textToShare = [NSString stringWithFormat:@"I have just finished %d times %@ solves using ChaoTimer, average: %@, best time: %@, are you wanna try?", num, scrambleType, avg, best];
                } else if (num < 12) {
                    textToShare = [NSString stringWithFormat:@"I have just finished %d times %@ solves using ChaoTimer, average: %@, best time: %@, best avg5: %@, are you wanna try?", num, scrambleType, avg, best, best5];
                } else if (num < 100) {
                    textToShare = [NSString stringWithFormat:@"I have just finished %d times %@ solves using ChaoTimer, average: %@, best time: %@, best avg5: %@, best avg12: %@, are you wanna try?", num, scrambleType, avg, best, best5, best12];
                } else {
                    textToShare = [NSString stringWithFormat:@"I have just finished %d times %@ solves using ChaoTimer, average: %@, best time: %@, best avg5: %@, best avg12: %@, best avg100: %@, are you wanna try?", num, scrambleType, avg, best, best5, best12, best100];
                }
            }
            break;
        case ShareTypeCopy:
        {
            NSString* date;
            NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"YYYY-MM-dd hh:mm a"];
            date = [formatter stringFromDate:[NSDate date]];
            textToShare = [[[CHTUtil getLocalizedString:@"Generate by"] stringByAppendingFormat:@"%@\n\n", date] stringByAppendingString:[session toString:YES]];
        }
            break;
        default:
            break;
    }
    NSLog(@"%@", textToShare);
    return textToShare;
}

@end
