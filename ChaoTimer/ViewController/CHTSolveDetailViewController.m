//
//  CHTSolveDetailViewController.m
//  ChaoTimer
//
//  Created by Jichao Li on 10/5/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import "CHTSolveDetailViewController.h"

#define FONT_SIZE 14.0f
#define CELL_CONTENT_MARGIN 10.0f

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
            [cell.textLabel setFont: [UIFont systemFontOfSize:30.0]];
            [cell.textLabel setText:[self.solve toString]];
            break;
        case 1:
            [cell.textLabel setFont: [UIFont systemFontOfSize:18.0]];
            [cell.textLabel setText:[self.solve.scramble getScrambleType]];
            break;
        case 2:
            [cell.textLabel setFont: [UIFont systemFontOfSize:18.0]];
            [cell.textLabel setText:[self.solve getTimeStampString]];
            break;
        case 3:
            [cell.textLabel setFont: [UIFont systemFontOfSize:FONT_SIZE]];
            [cell.textLabel setNumberOfLines:0];
            [cell.textLabel setText:[self.solve.scramble getScrambleString]];
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
            return 50.0f;
        case 1:
        case 2:
            return 44.0f;
        case 3:
            text = [self.solve.scramble getScrambleString];
            return [CHTUtil calculateCellHeightWithText:text fontSize:FONT_SIZE cellWidth:[CHTUtil getScreenWidth] cellMargin:CELL_CONTENT_MARGIN];
            break;
        default:
            return 44.0f;
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
