//
//  CHTStatsViewController.h
//  ChaoTimer
//
//  Created by Jichao Li on 10/2/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ShareSDK/ISSShareViewDelegate.h>

@interface CHTStatsViewController : UITableViewController <UIPopoverControllerDelegate, ISSShareViewDelegate>
@property (nonatomic, strong) NSMutableArray *stats;
@end
