//
//  CHTSessionViewController.m
//  ChaoTimer
//
//  Created by Jichao Li on 10/6/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import "CHTSessionViewController.h"

@interface CHTSessionViewController ()
@property NSMutableArray *buttons;
@end

@implementation CHTSessionViewController
@synthesize sessionManager;
@synthesize buttons;

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
    self.navigationItem.title = [CHTUtil getLocalizedString:@"session"];
    if ([CHTUtil getDevice] == DEVICE_PHONE) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backToStatsView:)];
    }
    [self.navigationController setToolbarHidden:NO];
    self.buttons = [[NSMutableArray alloc] init];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [self.editButtonItem setAction:@selector(editBtnPressed)];
    [self.buttons addObject:self.editButtonItem];
    [self.buttons addObject:flexibleSpace];
    UIBarButtonItem *newButton = [[UIBarButtonItem alloc] initWithTitle:[CHTUtil getLocalizedString:@"new session"] style:UIBarButtonItemStylePlain target:self action:@selector(addNewSession:)];
    [self.buttons addObject:newButton];
    [self setToolbarItems:self.buttons animated:NO];
    [self.tableView setAllowsSelectionDuringEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.sessionManager = [CHTSessionManager load];
    if ([CHTUtil getDevice] == DEVICE_PAD) {
        [self.navigationController.navigationBar setTintColor:[UIColor blackColor]];
        [self.navigationController.navigationBar setTitleTextAttributes:@{
          NSFontAttributeName:[CHTTheme font:FONT_REGULAR iphoneSize:22.0f ipadSize:22.0f],
        NSForegroundColorAttributeName: [UIColor blackColor]}];
    }
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.sessionManager save];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return [self.sessionManager stickySessionNum];
            break;
        case 1:
            return [self.sessionManager normalSessionNum];
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
    [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    switch (indexPath.section) {
        case 0: {
            NSString *title = [self.sessionManager getStickySessionAt:indexPath.row];
            CHTSession *session = [CHTSessionManager loadSessionWithName:title];
            NSString *subTitle = [NSString stringWithFormat:@"%@%d", [CHTUtil getLocalizedString:@"Number of solves: "], [session numberOfSolves]];
            if (indexPath.row == 0) {
                cell.textLabel.text = [CHTUtil getLocalizedString:title];

            } else
                cell.textLabel.text = title;
            cell.detailTextLabel.text = subTitle;
            if (indexPath.row == 0) {
                cell.imageView.image = [UIImage imageNamed:@"mainSession.png"];
            } else
                cell.imageView.image = [UIImage imageNamed:@"sticky.png"];
            
            if ([title isEqualToString:self.sessionManager.currentSessionName]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            break;
        }
        case 1: {
            NSString *title = [self.sessionManager getNormalSessionAt:indexPath.row];
            CHTSession *session = [CHTSessionManager loadSessionWithName:title];
            NSString *subTitle = [NSString stringWithFormat:@"%@%d", [CHTUtil getLocalizedString:@"Number of solves: "], [session numberOfSolves]];
            cell.textLabel.text = title;
            cell.detailTextLabel.text = subTitle;
            cell.imageView.image = [UIImage imageNamed:@"session.png"];
            if ([title isEqualToString:self.sessionManager.currentSessionName]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
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


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    return NO;
                default:
                    return YES;
            }
        default:
            return YES;
    }
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSString *deleteSession = @"";
        switch (indexPath.section) {
            case 0: {
                NSString *deleteSession = [self.sessionManager getStickySessionAt:indexPath.row];
                if ([deleteSession isEqualToString:self.sessionManager.currentSessionName]) {
                    self.sessionManager.currentSessionName = @"main session";
                }
                [self.sessionManager removeStickySessionAtIndex:indexPath.row];
                break;
            }
            case 1: {
                NSString *deleteSession = [self.sessionManager getNormalSessionAt:indexPath.row];
                if ([deleteSession isEqualToString:self.sessionManager.currentSessionName]) {
                    self.sessionManager.currentSessionName = @"main session";
                }
                [self.sessionManager removeNormalSessionAtIndex:indexPath.row];
                break;
            }
            default:
                deleteSession = self.sessionManager.currentSessionName;
                break;
        }
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
        [self.sessionManager save];
        [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.5];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }

}



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [self.sessionManager moveObjectFrom:fromIndexPath toIndexPath:toIndexPath];
    [self.sessionManager save];
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if ((sourceIndexPath.section == 0 && sourceIndexPath.row ==0) || (proposedDestinationIndexPath.section == 0 && proposedDestinationIndexPath.row == 0)) {
        return sourceIndexPath;
    } else {
        return proposedDestinationIndexPath;
    }
}


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    return NO;
                default:
                    return YES;
            }
        default:
            return YES;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.tableView.isEditing) {
        [[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] setSelectionStyle:UITableViewCellSelectionStyleNone];
        switch (indexPath.section) {
            case 0:
                switch (indexPath.row) {
                    case 0:
                        [[self.tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
                        break;
                    default:
                        [self editSession:indexPath];
                        break;
                }
                break;
            default:
                [self editSession:indexPath];
                break;
        }
        
    } else {
        NSString *session = @"main session";
        switch (indexPath.section) {
            case 0:
                session = [self.sessionManager getStickySessionAt:indexPath.row];
                break;
            case 1:
                session = [self.sessionManager getNormalSessionAt:indexPath.row];
                break;
            default:
                break;
        }
        self.sessionManager.currentSessionName = session;
        [[self.tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
        [self.sessionManager save];
        [self.tableView reloadData];
        
    }
}

- (IBAction) editBtnPressed
{
    if ([self isEditing])
    {
        [self setEditing:NO animated:YES];
        [self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.6];
    }
    else
    {
        [self setEditing:YES animated:YES];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [CHTUtil getLocalizedString:@"stickySessions"];
            break;
        case 1:
            return [CHTUtil getLocalizedString:@"mySessions"];
            break;
        default:
            return @"";
            break;
    }
}

- (IBAction)addNewSession:(id)sender {
    CHTEditSessionViewController *newSessionViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"editSession"];
    newSessionViewController.navigationItem.title = [CHTUtil getLocalizedString:@"new session"];
    newSessionViewController.isNew = YES;
    [self.navigationController pushViewController:newSessionViewController animated:YES];
    
}

- (void)editSession:(NSIndexPath *)indexPath {
    CHTEditSessionViewController *newSessionViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"editSession"];
    newSessionViewController.navigationItem.title = [CHTUtil getLocalizedString:@"rename session"];
    newSessionViewController.isNew = NO;
    if (indexPath.section == 0) {
        newSessionViewController.oldSessionName = [self.sessionManager getStickySessionAt:indexPath.row];
    } else
        newSessionViewController.oldSessionName =[self.sessionManager getNormalSessionAt:indexPath.row];
    [self.navigationController pushViewController:newSessionViewController animated:YES];
    
}


#pragma mark - Navigation

- (IBAction)backToStatsView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
