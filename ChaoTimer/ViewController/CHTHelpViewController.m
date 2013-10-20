//
//  CHTHelpViewController.m
//  ChaoTimer
//
//  Created by Jichao Li on 9/30/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import "CHTHelpViewController.h"

@interface CHTHelpViewController ()
@end

@implementation CHTHelpViewController
@synthesize helps = _helps;
@synthesize helpsToDo = _helpsToDo;
@synthesize helpsImage = _helpsImage;

- (NSArray *)helps {
    if (!_helps) {
        _helps = [[NSArray alloc] initWithObjects:
                  [CHTUtil getLocalizedString:@"1fhold"],
                  [CHTUtil getLocalizedString:@"sr"],
                  [CHTUtil getLocalizedString:@"sl"],
                  [CHTUtil getLocalizedString:@"1f2t"],
                  [CHTUtil getLocalizedString:@"2f2t"],
                  [CHTUtil getLocalizedString:@"2fup"], nil];
    }
    return _helps;
}

- (NSArray *)helpsToDo {
    if (!_helpsToDo) {
        _helpsToDo = [[NSArray alloc] initWithObjects:
                      [CHTUtil getLocalizedString:@"1fholdto"],[CHTUtil getLocalizedString:@"srto"], [CHTUtil getLocalizedString:@"slto"],[CHTUtil getLocalizedString:@"1f2tto"], [CHTUtil getLocalizedString:@"2f2tto"], [CHTUtil getLocalizedString:@"2fupto"],nil];
    }
    return _helpsToDo;
}

- (NSArray *)helpsImage {
    if (!_helpsImage) {
        _helpsImage = [[NSArray alloc] initWithObjects:
                       [UIImage imageNamed:@"1hold.png"],
                       [UIImage imageNamed:@"1fr.png"],
                       [UIImage imageNamed:@"1fl.png"],
                       [UIImage imageNamed:@"1f2t.png"],
                       [UIImage imageNamed:@"2f2t.png"],
                       [UIImage imageNamed:@"2fup.png"], nil];
    }
    return _helpsImage;
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
    [super viewDidLoad];
    self.navigationItem.title = [CHTUtil getLocalizedString:@"Gestures Help"];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.helps count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [self.helpsToDo objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [self.helps objectAtIndex:indexPath.row];
    cell.imageView.image = [self.helpsImage objectAtIndex:indexPath.row];
    [cell.textLabel setFont:[CHTTheme font:FONT_REGULAR iphoneSize:19.0f ipadSize:22.0f]];
    [cell.detailTextLabel setFont:[CHTTheme font:FONT_LIGHT iphoneSize:14.0f ipadSize:15.0f]];
    
    [cell.detailTextLabel setTextColor:[UIColor darkGrayColor]];
    return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([CHTUtil getDevice] == DEVICE_PHONE) {
        return 60;
    } else {
        return 80;
    }
}

-(NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [indexPath row];
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
