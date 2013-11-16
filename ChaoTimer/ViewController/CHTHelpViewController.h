//
//  CHTHelpViewController.h
//  ChaoTimer
//
//  Created by Jichao Li on 9/30/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHTUtil.h"
#import "CHTTheme.h"
#import <ShareSDK/ISSShareViewDelegate.h>

@interface CHTHelpViewController : UITableViewController <ISSShareViewDelegate>
@property (nonatomic, strong) NSArray *helps;
@property (nonatomic, strong) NSArray *helpsToDo;
@property (nonatomic, strong) NSArray *helpsImage;
@end
