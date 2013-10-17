//
//  CHTEditSessionViewController.h
//  ChaoTimer
//
//  Created by Jichao Li on 10/6/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHTSessionManager.h"
#import "CHTUtil.h"
#import "CHTTheme.h"

@interface CHTEditSessionViewController : UITableViewController <UITextFieldDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) UITextField *myTextField;
@property BOOL isNew;
@property NSString *oldSessionName;
@property (nonatomic, strong) CHTSessionManager *sessionManager;
@end
