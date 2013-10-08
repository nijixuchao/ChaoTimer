//
//  CHTStatsViewController.h
//  ChaoTimer
//
//  Created by Jichao Li on 10/2/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHTTheme.h"
#import "CHTSettings.h"
#import "CHTUtil.h"
#import "CHTSession.h"
#import "CHTSessionManager.h"
#import "CHTOneStat.h"
#import "CHTStatDetailViewController.h"
#import "CHTSessionViewController.h"

@interface CHTStatsViewController : UITableViewController <UIPopoverControllerDelegate>
@property (nonatomic, strong) NSMutableArray *stats;
@end
