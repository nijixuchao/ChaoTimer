//
//  CHTEditSessionViewController.m
//  ChaoTimer
//
//  Created by Jichao Li on 10/6/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import "CHTEditSessionViewController.h"

@interface CHTEditSessionViewController ()

@end

@implementation CHTEditSessionViewController
@synthesize myTextField;
@synthesize isNew;
@synthesize oldSessionName;
@synthesize sessionManager;

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
    self.sessionManager = [CHTSessionManager load];
}

- (void)viewWillDisappear:(BOOL)animated{
    NSLog(@"view will disappear");
    [myTextField resignFirstResponder];
    [super viewWillDisappear:animated];
    
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
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [self.view setNeedsDisplay];
    myTextField = [[UITextField alloc]initWithFrame:CGRectMake(20,5,280,36)];
    myTextField.borderStyle = UITextBorderStyleNone;
    myTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    myTextField.placeholder = [CHTUtil getLocalizedString:@"inputSessionName"];
    myTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    myTextField.returnKeyType = UIReturnKeyDone;
    if (!isNew) {
        myTextField.text = oldSessionName;
    }
    myTextField.enablesReturnKeyAutomatically = YES;
    myTextField.delegate = self;
    [myTextField setFont:[CHTTheme font:FONT_REGULAR iphoneSize:17.0f ipadSize:17.0f]];
    [myTextField becomeFirstResponder];
    
    [cell addSubview:myTextField];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [CHTUtil getLocalizedString:@"sessionName"];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return [CHTUtil getLocalizedString:@"sessionNameDup"];
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"should return");
    if (self.isNew) {
        NSString *newSession = textField.text;
        //NSLog(newSession);
        if([sessionManager hasSession:newSession]) {
            textField.text = @"";
            [textField resignFirstResponder];
            UIAlertView *duplicateName = [[UIAlertView alloc] initWithTitle:[CHTUtil getLocalizedString:@"dup warning"] message:[CHTUtil getLocalizedString:@"choose another name"] delegate:self cancelButtonTitle:[CHTUtil getLocalizedString:@"ok"] otherButtonTitles:nil];
            [duplicateName show];
            return NO;
        } else {
            [self.sessionManager addSession:newSession];
            [self.sessionManager save];
            [self.navigationController popViewControllerAnimated:YES];
            return YES;
        }
    } else {
        NSString *newSession = textField.text;
        //NSLog(newSession);
        if((![newSession isEqualToString:oldSessionName]) &&[sessionManager hasSession:newSession]) {
            textField.text = oldSessionName;
            [textField resignFirstResponder];
            UIAlertView *duplicateName = [[UIAlertView alloc] initWithTitle:[CHTUtil getLocalizedString:@"dup warning"] message:[CHTUtil getLocalizedString:@"choose another name"] delegate:self cancelButtonTitle:[CHTUtil getLocalizedString:@"OK"] otherButtonTitles:nil];
            [duplicateName show];
            //[self.myTextField becomeFirstResponder];
            return NO;
        } else {
            [self.sessionManager renameSession:oldSessionName to:newSession];
            [self.sessionManager save];
            [self.navigationController popViewControllerAnimated:YES];
            return YES;
        }
        
    }
}

- (void)dismissNamedAlert: (UIAlertView*)alert
{
    [alert dismissWithClickedButtonIndex:0 animated:YES];
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
