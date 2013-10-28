//
//  CHTLicenseViewController.m
//  ChaoTimer
//
//  Created by Jichao Li on 10/27/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import "CHTLicenseViewController.h"
#import "CHTUtil.h"

@interface CHTLicenseViewController ()
@end

@implementation CHTLicenseViewController
@synthesize webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = [CHTUtil getLocalizedString:@"license"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"license" ofType:@"html"] isDirectory:NO]]];

    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
