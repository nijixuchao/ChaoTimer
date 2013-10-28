//
//  CHTThemeViewController.m
//  ChaoTimer
//
//  Created by Jichao Li on 10/6/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import "CHTThemeViewController.h"

@interface CHTThemeViewController ()

@end

@implementation CHTThemeViewController
@synthesize themes;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = [CHTUtil getLocalizedString:@"theme"];
    self.themes = [CHTTheme getAllTheme];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.themes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    CHTTheme *theme = [CHTTheme initWithTheme:(Theme)[[themes objectAtIndex:indexPath.row] intValue]];
    cell.textLabel.text = theme.getMyThemeName;
    [cell.textLabel setTextColor:theme.textColor];
    if (theme.myTheme == [CHTTheme getTimerTheme].myTheme) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    [cell.textLabel setFont:[CHTTheme font:FONT_REGULAR iphoneSize:18.0f ipadSize:18.0f]];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"will display cell");
    [cell setBackgroundColor:[CHTTheme getColorFromTheme:(Theme)[[themes objectAtIndex:indexPath.row] intValue]]];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [CHTUtil getLocalizedString:@"select theme"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO animated:YES];
    CHTTheme *theme = [CHTTheme initWithTheme:(Theme)[[themes objectAtIndex:indexPath.row] intValue]];
    [theme save];
    [theme setNavigationControllerTheme];
    [theme setNavigationControllerTheme:self.navigationController];
    [self.tabBarController.tabBar setBarTintColor: theme.tabBarColor];
    [self.tableView reloadData];
}

@end
