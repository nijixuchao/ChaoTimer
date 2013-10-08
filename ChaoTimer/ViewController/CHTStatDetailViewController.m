//
//  CHTStatDetailViewController.m
//  ChaoTimer
//
//  Created by Jichao Li on 10/5/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import "CHTStatDetailViewController.h"

@interface CHTStatDetailViewController ()
@property CHTSolve *best, *worst;
@end

@implementation CHTStatDetailViewController

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
    //[[CHTTheme getTimerTheme] setNavigationControllerTheme:self.navigationController];
    self.navigationItem.title = [CHTUtil getLocalizedString:@"Detail"];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    //[self updateStatDetail];
    NSLog(@"stat detail will appear");
    [super viewWillAppear:animated];
    [self reload];
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
            return 1;
        case 1:
            return self.statDetails.count;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    switch (indexPath.section) {
        case 0:
            [cell.textLabel setText:[CHTUtil getLocalizedString:self.stat.statType]];
            [cell.detailTextLabel setText:self.stat.statValue];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [cell setAccessoryType: UITableViewCellAccessoryNone];
            break;
        case 1:
        {
            CHTSolve *solve = [self.statDetails objectAtIndex:indexPath.row];
            if ([solve isEqual:self.best] || [solve isEqual:self.worst]) {
                cell.textLabel.text = [NSString stringWithFormat:@"( %@ )", [solve toString]];
            } else {
                cell.textLabel.text = [solve toString];
            }
            cell.detailTextLabel.text = [solve getTimeStampString];
        }
            break;
            
        default:
            break;
    }
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"will display cell");
    if (indexPath.row % 2 == 1) {
        [cell setBackgroundColor:[UIColor colorWithRed:240/255.0f green:240/255.0f blue:240/255.0f alpha:1]];
    } else {
        [cell setBackgroundColor:[UIColor whiteColor]];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            if ([self.session.sessionName isEqualToString:@"main session"]) {
                return [CHTUtil getLocalizedString:@"main session"];
            } else
                return self.session.sessionName;
            break;
        case 1:
            return [CHTUtil getLocalizedString:@"solve list"];
        default:
            return @"";
            break;
    }
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


#pragma mark - Navigation

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO animated:YES];
    if (indexPath.section == 1) {
        CHTSolve *solve = [self.statDetails objectAtIndex:indexPath.row];
        CHTSolveDetailViewController *solveDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"oneSolveDetail"];
        solveDetailViewController.hidesBottomBarWhenPushed = YES;
        solveDetailViewController.solve = solve;
        [self.navigationController pushViewController:solveDetailViewController animated:YES];
    }
}


/*
// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

- (void)reload{
    self.best = self.statDetails.lastObject;
    self.worst = self.statDetails.lastObject;
    for (CHTSolve *aTime in self.statDetails) {
        if (aTime.timeAfterPenalty > self.worst.timeAfterPenalty) {
            self.worst = aTime;
        }
        if (aTime.timeAfterPenalty < self.best.timeAfterPenalty) {
            self.best = aTime;
        }
    }
    [self.tableView reloadData];
}


@end
