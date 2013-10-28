//
//  CHTStatDetailViewController.m
//  ChaoTimer
//
//  Created by Jichao Li on 10/5/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import "CHTStatDetailViewController.h"
#import "CHTTheme.h"
#import "CHTSettings.h"
#import "CHTUtil.h"
#import "CHTSession.h"
#import "CHTSessionManager.h"
#import "CHTOneStat.h"
#import "CHTSolveDetailViewController.h"

@interface CHTStatDetailViewController ()
@property (nonatomic, strong) CHTSolve *best, *worst;
@property (nonatomic, strong) CHTTheme *timerTheme;
@property (nonatomic) int solveOrder;
@end

@implementation CHTStatDetailViewController
@synthesize statDetails;
@synthesize session;
@synthesize stat;
@synthesize row;
@synthesize best;
@synthesize worst;
@synthesize timerTheme;
@synthesize solveOrder;

int solveDetailDisplay;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (int)solveOrder {
    return [CHTSettings getSavedInt:@"solveOrder"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = [CHTUtil getLocalizedString:@"Detail"];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.timerTheme = [CHTTheme getTimerTheme];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"stat detail will appear");
    [super viewWillAppear:animated];
    [self getBestAndWorst];
    [self.tableView reloadData];
    solveDetailDisplay = [CHTSettings getSavedInt:@"solveDetailDisplay"];
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
        {
            if (indexPath.row == 0) {
                [cell.textLabel setText:[CHTUtil getLocalizedString:self.stat.statType]];
                [cell.detailTextLabel setText:self.stat.statValue];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                NSArray *solveOrders = [[NSArray alloc] initWithObjects:[CHTUtil getLocalizedString:@"↓"], [CHTUtil getLocalizedString:@"↑"], nil];
                UISegmentedControl *solveOrderSegment = [[UISegmentedControl alloc] initWithItems:solveOrders];
                
                [solveOrderSegment setTintColor:[self.timerTheme getTintColor]];
                int order = [CHTSettings getSavedInt:@"solveOrder"];
                [solveOrderSegment setSelectedSegmentIndex:order];
                [solveOrderSegment addTarget:self action:@selector(solveOrderSegmentChange:) forControlEvents:UIControlEventValueChanged];
                cell.accessoryView = solveOrderSegment;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            } else {
                cell.accessoryView = nil;
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
            break;
        }
        case 1:
        {
            CHTSolve *solve;
            if (self.solveOrder == 1) {
                solve = [self.statDetails objectAtIndex:(self.statDetails.count - 1 -indexPath.row)];
            } else {
                solve = [self.statDetails objectAtIndex:indexPath.row];
            }
            
            if ([solve isEqual:self.best] || [solve isEqual:self.worst]) {
                cell.textLabel.text = [NSString stringWithFormat:@"( %@ )", [solve toString]];
            } else {
                cell.textLabel.text = [solve toString];
            }
            switch (solveDetailDisplay) {
                case 0:
                    cell.detailTextLabel.text = [solve getTimeStampString];
                    break;
                case 1:
                    cell.detailTextLabel.text = solve.scramble.scramble;
                    break;
                case 2:
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", solve.scramble.scrType, solve.scramble.scrSubType];
                    break;
                default:
                    cell.detailTextLabel.text = [solve getTimeStampString];
                    break;
            }
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
            cell.accessoryView = nil;
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            break;
        }
        default:
            break;
    }
    [cell.textLabel setFont:[CHTTheme font:FONT_REGULAR iphoneSize:18.0f ipadSize:18.0f]];
    [cell.detailTextLabel setFont:[CHTTheme font:FONT_LIGHT iphoneSize:12.0f ipadSize:12.0f]];
    [cell.detailTextLabel setTextColor:[UIColor darkGrayColor]];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"will display cell");
    if (indexPath.section == 1) {
        if (indexPath.row % 2 == 1) {
            [cell setBackgroundColor:[UIColor colorWithRed:240/255.0f green:240/255.0f blue:240/255.0f alpha:1]];
        } else {
            [cell setBackgroundColor:[UIColor whiteColor]];
        }
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


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return NO;
    } else {
        return YES;
    }
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        CHTSolve *solve;
        if (self.solveOrder == 1) {
            solve = [self.statDetails objectAtIndex:(self.statDetails.count - 1 -indexPath.row)];
        } else {
            solve = [self.statDetails objectAtIndex:indexPath.row];
        }
        [self.session removeSolve:solve];
        [self.statDetails removeObjectAtIndex:indexPath.row];
        [CHTSessionManager saveSession:self.session];
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];

        [[self.tabBarController.tabBar.items objectAtIndex:0] setBadgeValue:[NSString stringWithFormat:@"%d", self.session.numberOfSolves]];
        [self reload];
        @try {
            [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
        }
        @catch (NSException *exception) {
            NSLog(@"Exception: %@", exception);
        }
        @finally {
        }

    }
}


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
        CHTSolve *solve;
        if (self.solveOrder == 1) {
            solve = [self.statDetails objectAtIndex:(self.statDetails.count - 1 -indexPath.row)];
        } else {
            solve = [self.statDetails objectAtIndex:indexPath.row];
        }
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
    [self.statDetails removeAllObjects];
    switch (self.row) {
        case 3:
            // session avg
            if (self.session.numberOfSolves == 0) {
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
            self.statDetails = [self.session getAllSolves];
            self.stat.statValue = [[self.session sessionAvg] toString];
            break;
        case 4:
            // session mean
            if (self.session.numberOfSolves == 0) {
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
            self.statDetails = [self.session getAllSolves];
            self.stat.statValue = [[self.session sessionMean] toString];
            break;
        case 5:
            // current 5
            if (self.session.numberOfSolves < 5) {
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
            self.statDetails = [self.session getCurrent:5];
            self.stat.statValue = [[self.session currentAvgOf:5] toString];
            break;
        case 6:
            // best 5
            if (self.session.numberOfSolves < 5) {
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
            self.statDetails = [self.session getBest:5];
            self.stat.statValue = [[self.session bestAvgOf:5] toString];
            break;
        case 7:
            // current 12
            if (self.session.numberOfSolves < 12) {
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
            self.statDetails = [self.session getCurrent:12];
            self.stat.statValue = [[self.session currentAvgOf:12] toString];
            break;
        case 8:
            // best 12
            if (self.session.numberOfSolves < 12) {
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
            self.statDetails = [self.session getBest:12];
            self.stat.statValue = [[self.session bestAvgOf:12] toString];
            break;
        case 9:
            // current 100
            if (self.session.numberOfSolves < 100) {
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
            self.statDetails = [self.session getCurrent:100];
            self.stat.statValue = [[self.session currentAvgOf:100] toString];
            break;
        case 10:
            // best 100
            if (self.session.numberOfSolves < 100) {
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
            self.statDetails = [self.session getBest:100];
            self.stat.statValue = [[self.session bestAvgOf:100] toString];
            break;
        default:
            [self.navigationController popViewControllerAnimated:YES];
            break;
    }
    [self getBestAndWorst];
    [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
}

- (void)getBestAndWorst{
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

}

- (IBAction)solveOrderSegmentChange:(id)sender {
    NSLog(@"solveOrderSegmentChange");
    UISegmentedControl *segCtrl = (UISegmentedControl *)sender;
    [CHTSettings saveInt:segCtrl.selectedSegmentIndex forKey:@"solveOrder"];
    [self reload];
}

@end
