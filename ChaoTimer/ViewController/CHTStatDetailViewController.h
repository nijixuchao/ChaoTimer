//
//  CHTStatDetailViewController.h
//  ChaoTimer
//
//  Created by Jichao Li on 10/5/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHTTheme.h"
#import "CHTSettings.h"
#import "CHTUtil.h"
#import "CHTSession.h"
#import "CHTSessionManager.h"
#import "CHTOneStat.h"
#import "CHTSolveDetailViewController.h"

@interface CHTStatDetailViewController : UITableViewController
@property (nonatomic, strong) NSMutableArray *statDetails;
@property (nonatomic, strong) CHTSession *session;
@property (nonatomic) CHTOneStat *stat;
@property (nonatomic) int row;
@end
