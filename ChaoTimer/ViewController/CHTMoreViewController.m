//
//  CHTMoreViewController.m
//  ChaoTimer
//
//  Created by Jichao Li on 9/30/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import "CHTMoreViewController.h"


@interface CHTMoreViewController ()
@property (nonatomic, strong) CHTTheme *timerTheme;
@end

@implementation CHTMoreViewController
@synthesize timerTheme;

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
    self.navigationItem.title = [CHTUtil getLocalizedString:@"More"];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 2;
            break;
        case 2:
            return 3;
            break;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                {
                    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
                    cell.textLabel.text = [CHTUtil getLocalizedString:@"version"];
                    cell.detailTextLabel.text = version;
                    cell.imageView.image = [UIImage imageNamed:@"version.png"];
                    [cell setAccessoryType:UITableViewCellAccessoryNone];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    break;
                }
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = [CHTUtil getLocalizedString:@"theme"];
                    cell.detailTextLabel.text = [self.timerTheme getMyThemeName];
                    cell.imageView.image = [UIImage imageNamed:@"theme.png"];
                    break;
                case 1:
                    cell.textLabel.text = [CHTUtil getLocalizedString:@"setting"];
                    cell.detailTextLabel.text = @"";
                    cell.imageView.image = [UIImage imageNamed:@"setting.png"];
                    break;
                default:
                    break;
            }
            break;
        case 2:
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = [CHTUtil getLocalizedString:@"rate"];
                    cell.detailTextLabel.text = @"";
                    cell.imageView.image = [UIImage imageNamed:@"rate.png"];
                    break;
                case 1:
                    cell.textLabel.text = [CHTUtil getLocalizedString:@"send feedback"];
                    cell.detailTextLabel.text = @"";
                    cell.imageView.image = [UIImage imageNamed:@"feedback.png"];
                    break;
                case 2:
                    cell.textLabel.text = [CHTUtil getLocalizedString:@"tell friends"];
                    cell.detailTextLabel.text = @"";
                    cell.imageView.image = [UIImage imageNamed:@"tell_friends.png"];
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    [cell.detailTextLabel setTextColor:[timerTheme getTintColor]];
    [cell.textLabel setFont:[CHTTheme font:FONT_REGULAR iphoneSize:17.0f ipadSize:17.0f]];
    [cell.detailTextLabel setFont:[CHTTheme font:FONT_LIGHT iphoneSize:17.0f ipadSize:17.0f]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO animated:YES];
    switch (indexPath.section) {
        case 0:
            break;
        case 1:
            switch (indexPath.row) {
                case 0: {
                    CHTThemeViewController *themeViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ThemeControl"];
                    themeViewController.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:themeViewController animated:YES];
                    break;
                }
                    
                default:
                    break;
            }
            break;
        case 2:
            switch (indexPath.row) {
                case 0:
                    [self rateForApp];
                    break;
                case 1:
                    [self sendFeedback];
                    break;
                case 2:
                    [self tellFriends];
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
}

- (IBAction) tellFriends {
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:[CHTUtil getLocalizedString:@"mailSubject"]];
    [mc setMessageBody:[CHTUtil getLocalizedString:@"mailBody"] isHTML:YES];
    [mc setModalPresentationStyle:UIModalPresentationFormSheet];
    [self presentViewController:mc animated:YES completion:nil];
}

- (IBAction) sendFeedback {
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:@"Feedback of ChaoTimer"];
    [mc setToRecipients:[NSArray arrayWithObjects:@"nijixuchao@gmail.com", nil]];
    [mc setModalPresentationStyle:UIModalPresentationFormSheet];
    [self presentViewController:mc animated:YES completion:nil];
}


- (IBAction)rateForApp {
    NSLog(@"===== openURL! =====");
    NSString *str = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d", 537516001];
    NSLog(@"URL string:%@",str);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail send canceled...");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved...");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent...");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail send errored: %@...", [error localizedDescription]);
            break;
        default:
            break;
    }
    [self.tableView reloadData];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
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

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

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

@end
