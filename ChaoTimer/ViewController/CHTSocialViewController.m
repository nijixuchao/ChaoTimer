//
//  CHTSocialViewController.m
//  ChaoTimer
//
//  Created by Jichao Li on 10/22/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import "CHTSocialViewController.h"
#import "CHTSettings.h"
#import "CHTSocial.h"
#import "CHTSocialObject.h"
#import "CHTTheme.h"
#import <ShareSDK/ShareSDK.h>

@interface CHTSocialViewController ()
@property (nonatomic, strong) NSMutableArray *shareList;
@property (nonatomic, strong) NSMutableArray *notShareList;
@property (nonatomic, strong) CHTTheme *timerTheme;
@end

@implementation CHTSocialViewController
@synthesize shareList = _shareList;
@synthesize notShareList = _notShareList;
@synthesize timerTheme;

- (NSMutableArray *)shareList {
    if (!_shareList) {
        NSLog(@"no share list");
        _shareList = [CHTSocial getShareTypeList];
    }
    return _shareList;
}

- (NSMutableArray *)notShareList {
    if (!_notShareList) {
        NSLog(@"no not share list");
        _notShareList = [CHTSocial getNotShareTypeList];
    }
    return _notShareList;
}

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
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults removeObjectForKey:@"shareList"];
//    [defaults removeObjectForKey:@"notShareList"];
//    [defaults synchronize];
    [super viewDidLoad];
    self.navigationItem.title = [CHTUtil getLocalizedString:@"social"];
    self.timerTheme = [CHTTheme getTimerTheme];
        NSLog(@"share list count: %d, not share count: %d", self.shareList.count, self.notShareList.count);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setEditing:YES animated:YES];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return self.shareList.count;
        case 1:
            return self.notShareList.count;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    ShareType type;
    switch (indexPath.section) {
        case 0:
            type = (ShareType)([(NSNumber *)[self.shareList objectAtIndex:indexPath.row] intValue]);
            break;
        case 1:
            type = (ShareType)([(NSNumber *)[self.notShareList objectAtIndex:indexPath.row] intValue]);
            break;
        default:
            type = 0;
            break;
    }
    CHTSocialObject *socialObj = [CHTSocialObject initWithType:type];
    cell.textLabel.text = [socialObj toString];
    if ([socialObj needAuth]) {
        UISwitch *socialSwitch = [[UISwitch alloc] init];
        [socialSwitch addTarget:self action:@selector(socialSwitchAction:) forControlEvents:UIControlEventValueChanged];
        if ([socialObj isAuthed]) {
            [socialSwitch setOn:YES];
        } else {
            [socialSwitch setOn:NO];
        }
        [socialSwitch setTag:type];
        cell.editingAccessoryView = socialSwitch;
    } else {
        cell.editingAccessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.font = [CHTTheme font:FONT_REGULAR iphoneSize:18.0f ipadSize:18.0f];
    cell.imageView.image = [socialObj getSmallImage];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    return cell;
}

- (IBAction)socialSwitchAction:(id)sender {
    UISwitch *switchButton = (UISwitch*)sender;
    ShareType type = switchButton.tag;
    CHTSocialObject *socialObj = [CHTSocialObject initWithType:type];
    BOOL isButtonOn = [switchButton isOn];
    if (isButtonOn) {
        [socialObj authWithDelegate:self tableView:self.tableView];
    }else {
        [socialObj unAuth];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [CHTUtil getLocalizedString:@"include"];
        case 1:
            return [CHTUtil getLocalizedString:@"notInclude"];
        default:
            return @"";
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return [CHTUtil getLocalizedString:@"socialFooter"];
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return NO;
 }
*/

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSLog(@"Move from Section %d, Row %d to Section %d, Row %d", fromIndexPath.section, fromIndexPath.row, toIndexPath.section, toIndexPath.row);
    if (fromIndexPath.section == toIndexPath.section && fromIndexPath.section == 0) {
        if (fromIndexPath.row != toIndexPath.row) {
            id obj = [self.shareList objectAtIndex:fromIndexPath.row];
            [self.shareList removeObjectAtIndex:fromIndexPath.row];
            if (toIndexPath.row >= [self.shareList count]) {
                [self.shareList addObject:obj];
            } else {
                [self.shareList insertObject:obj atIndex:toIndexPath.row];
            }
        }
    } else if (fromIndexPath.section == toIndexPath.section && fromIndexPath.section == 1) {
        if (fromIndexPath.row != toIndexPath.row) {
            id obj = [self.notShareList objectAtIndex:fromIndexPath.row];
            [self.notShareList removeObjectAtIndex:fromIndexPath.row];
            if (toIndexPath.row >= [self.notShareList count]) {
                [self.notShareList addObject:obj];
            } else {
                [self.notShareList insertObject:obj atIndex:toIndexPath.row];
            }
            
        }
    } else if (fromIndexPath.section != toIndexPath.section) {
        if (fromIndexPath.section == 0) {
            id obj = [self.shareList objectAtIndex:fromIndexPath.row];
            [self.shareList removeObjectAtIndex:fromIndexPath.row];
            if (toIndexPath.row >= [self.notShareList count]) {
                [self.notShareList addObject:obj];
            } else {
                [self.notShareList insertObject:obj atIndex:toIndexPath.row];
            }
            
        } else {
            id obj = [self.notShareList objectAtIndex:fromIndexPath.row];
            [self.notShareList removeObjectAtIndex:fromIndexPath.row];
            if (toIndexPath.row >= [self.shareList count]) {
                [self.shareList addObject:obj];
            } else {
                [self.shareList insertObject:obj atIndex:toIndexPath.row];
            }
        }
    }
    NSLog(@"share list count: %d, not share count: %d", self.shareList.count, self.notShareList.count);
    [CHTSocial saveShareTypeList:self.shareList notShareList:self.notShareList];
}


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 
 */

- (void)viewOnWillDisplay:(UIViewController *)viewController shareType:(ShareType)shareType
{
    NSLog(@"view on will display delegate");
    
    UIButton *leftBtn = (UIButton *)viewController.navigationItem.leftBarButtonItem.customView;
    UIButton *rightBtn = (UIButton *)viewController.navigationItem.rightBarButtonItem.customView;
    
    leftBtn.backgroundColor = [UIColor clearColor];
    rightBtn.backgroundColor = [UIColor clearColor];
    [leftBtn setTitleColor:self.timerTheme.barItemColor forState:UIControlStateNormal];
    [leftBtn setTitleColor:[UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.5f] forState:UIControlStateHighlighted];
    [rightBtn setTitleColor:self.timerTheme.barItemColor forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.5f] forState:UIControlStateHighlighted];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = self.timerTheme.textColor;
    label.text = viewController.title;
    label.font = [CHTTheme font:FONT_REGULAR iphoneSize:22.0f ipadSize:22.0f];
    [label sizeToFit];
    
    viewController.navigationItem.titleView = label;
    [viewController.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [viewController.navigationController.navigationBar setBarTintColor:self.timerTheme.navigationColor];
}


@end
