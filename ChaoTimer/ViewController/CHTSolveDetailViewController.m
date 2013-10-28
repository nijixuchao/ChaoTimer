//
//  CHTSolveDetailViewController.m
//  ChaoTimer
//
//  Created by Jichao Li on 10/5/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import "CHTSolveDetailViewController.h"

#define FONT_SIZE 13.0f

@interface CHTSolveDetailViewController ()

@end

@implementation CHTSolveDetailViewController
@synthesize solve;

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
    self.navigationItem.title = [CHTUtil getLocalizedString:@"scramble"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(displayActionSheet)];
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
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    switch (indexPath.row) {
        case 0:
            [cell.textLabel setFont:[CHTTheme font:FONT_BOLD iphoneSize:35.0f ipadSize:35.0f]];
            [cell.detailTextLabel setFont:[CHTTheme font:FONT_LIGHT iphoneSize:17.0f ipadSize:17.0f]];
            [cell.textLabel setText:[self.solve toString]];
            if (self.solve.penalty != PENALTY_NO_PENALTY) {
                [cell.detailTextLabel setText:[NSString stringWithFormat:@"(%@)", [CHTUtil convertTimeFromMsecondToString:self.solve.timeBeforePenalty]]];
            } else {
                [cell.detailTextLabel setText:@""];
            }
            break;
        case 1:
            [cell.textLabel setFont:[CHTTheme font:FONT_REGULAR iphoneSize:20.0f ipadSize:20.0f]];
            [cell.detailTextLabel setFont:[CHTTheme font:FONT_LIGHT iphoneSize:17.0f ipadSize:17.0f]];
            [cell.textLabel setText:self.solve.scramble.scrType];
            [cell.detailTextLabel setText:self.solve.scramble.scrSubType];
            break;
        case 2:
            [cell.textLabel setFont:[CHTTheme font:FONT_REGULAR iphoneSize:17.0f ipadSize:17.0f]];
            [cell.detailTextLabel setFont:[CHTTheme font:FONT_LIGHT iphoneSize:17.0f ipadSize:17.0f]];
            [cell.textLabel setText:[self.solve getTimeStampString]];
            [cell.detailTextLabel setText:@""];
            break;
        case 3:
            [cell.textLabel setFont:[CHTTheme font:FONT_REGULAR iphoneSize:FONT_SIZE ipadSize:FONT_SIZE + 4]];
            [cell.textLabel setNumberOfLines:0];
            [cell.detailTextLabel setText:@""];
            [cell.textLabel setText:self.solve.scramble.scramble];
            break;
        default:
            break;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    // Get the text so we can measure it
    NSString *text;
    switch (indexPath.row) {
        case 0:
            return 55.0f;
        case 1:
        case 2:
            return 44.0f;
        case 3:
            text = self.solve.scramble.scramble;
            return [CHTUtil heightOfContent:text font:[CHTTheme font:FONT_REGULAR iphoneSize:FONT_SIZE ipadSize:FONT_SIZE + 4]];
        default:
            return 44.0f;
    }
}

- (void) displayActionSheet {
    if ([CHTUtil getDevice] == DEVICE_PAD) {
        if (shareSheet.visible) {
            [shareSheet dismissWithClickedButtonIndex:-1 animated:YES];
        } else {
            shareSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:[CHTUtil getLocalizedString: @"cancel"] destructiveButtonTitle:nil otherButtonTitles:[CHTUtil getLocalizedString: @"copy scramble"], nil];
            [shareSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
            [shareSheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
        }
    } else {
        shareSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:[CHTUtil getLocalizedString: @"cancel"] destructiveButtonTitle:nil otherButtonTitles:[CHTUtil getLocalizedString: @"copy scramble"], nil];
        [shareSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
        [shareSheet showInView:[UIApplication sharedApplication].keyWindow];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self copyToPaste];
            break;
        default:
            break;
    }
}

- (IBAction)copyToPaste {
    NSString *textToPaste = self.solve.scramble.scramble;
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = textToPaste;
    NSLog(@"%@", textToPaste);
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:[CHTUtil getLocalizedString: @"copy scramble success"] delegate:self cancelButtonTitle:[CHTUtil getLocalizedString: @"OK"] otherButtonTitles:nil];
    [alertView show];
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
