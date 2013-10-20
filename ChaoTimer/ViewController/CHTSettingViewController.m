//
//  CHTSettingViewController.m
//  ChaoTimer
//
//  Created by Jichao Li on 10/17/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import "CHTSettingViewController.h"
#import "CHTUtil.h"
#import "CHTSettings.h"
#import "CHTTheme.h"

@interface CHTSettingViewController ()
@property(nonatomic, strong) UILabel *fTime;
@property(nonatomic, strong) CHTTheme *timerTheme;
@end

@implementation CHTSettingViewController
@synthesize fTime;

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
    self.navigationItem.title = [CHTUtil getLocalizedString:@"setting"];
    self.timerTheme = [CHTTheme getTimerTheme];
    if ([CHTUtil getDevice] == DEVICE_PAD) {
        fTime = [[UILabel alloc]initWithFrame:CGRectMake(16, 25, 200, 15)];
    } else {
        fTime = [[UILabel alloc]initWithFrame:CGRectMake(16, 25, 200, 15)];
    }
    
    fTime.font = [CHTTheme font:FONT_LIGHT iphoneSize:13.0f ipadSize:13.0f];
    fTime.backgroundColor = [UIColor clearColor];
    fTime.textColor = [UIColor darkGrayColor];
    int time = [CHTSettings getSavedInt:@"freezeTime"];
    fTime.text = [NSString stringWithFormat:@"%0.1f s", (double)time*0.01];
    if ([fTime.text isEqualToString:@"0.0 s"]) {
        fTime.text = [fTime.text stringByAppendingString:[CHTUtil getLocalizedString:@"no other gesture"]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 2;
            break;
        case 1:
            return 2;
            break;
        default:
            break;
    }
    return 0;
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
                    cell.textLabel.text = [CHTUtil getLocalizedString:@"wca inspection"];
                    cell.detailTextLabel.text = [CHTUtil getLocalizedString:@"15 sec"];
                    UISwitch *wcaInsSwitch = [[UISwitch alloc] init];
                    [wcaInsSwitch setTag:1];
                    [wcaInsSwitch addTarget:self action:@selector(wcaSwitchAction:) forControlEvents:UIControlEventValueChanged];
                    if ([CHTSettings getSavedBool: @"wcaInspection"] == YES) {
                        [wcaInsSwitch setOn:YES];
                    }
                    else {
                        [wcaInsSwitch setOn:NO];
                    }
                    cell.accessoryView = wcaInsSwitch;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                }
                    
                case 1:
                {
                    cell.textLabel.text = [CHTUtil getLocalizedString:@"start freeze"];
                    [cell.detailTextLabel setText:@" "];
                    UISlider *freezeTime = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
                    [freezeTime setTintColor:[self.timerTheme getTintColor]];

                    freezeTime.minimumValue = 10;
                    freezeTime.maximumValue = 100;
                    [freezeTime addTarget:self action:@selector(freezeTimeSliderChanged:) forControlEvents:UIControlEventValueChanged];
                    int time = [CHTSettings getSavedInt:@"freezeTime"];
                    freezeTime.value = time;
                    [cell addSubview:fTime];
                    cell.accessoryView = freezeTime;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                }
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                {
                    [cell.textLabel setText:[CHTUtil getLocalizedString:@"newest time on"]];
                    NSArray *solveOrders = [[NSArray alloc] initWithObjects:[CHTUtil getLocalizedString:@"bottom"], [CHTUtil getLocalizedString:@"top"], nil];
                    UISegmentedControl *solveOrderSegment = [[UISegmentedControl alloc] initWithItems:solveOrders];
                    
                    [solveOrderSegment setTintColor:[self.timerTheme getTintColor]];
                    int order = [CHTSettings getSavedInt:@"solveOrder"];
                    [solveOrderSegment setSelectedSegmentIndex:order];
                    //[solveOrderSegment setFrame:CGRectMake(0, 0, 180, 30)];
                    [solveOrderSegment addTarget:self action:@selector(solveOrderSegmentChange:) forControlEvents:UIControlEventValueChanged];
                    cell.accessoryView = solveOrderSegment;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    [cell.detailTextLabel setText:@""];
                }
                    break;
                case 1:
                {
                    [cell.textLabel setText:[CHTUtil getLocalizedString:@"solve subtitle"]];
                    NSArray *solveDetails = [[NSArray alloc] initWithObjects:[CHTUtil getLocalizedString:@"time"], [CHTUtil getLocalizedString:@"scrStr"], [CHTUtil getLocalizedString:@"type"], nil];
                    UISegmentedControl *solveDetailSegment = [[UISegmentedControl alloc] initWithItems:solveDetails];
                    //[solveDetailSegment setFrame:CGRectMake(0, 0, 180, 30)];
                    [solveDetailSegment addTarget:self action:@selector(solveDetailSegmentChange:) forControlEvents:UIControlEventValueChanged];
                    [solveDetailSegment setTintColor:[self.timerTheme getTintColor]];
                    int detail = [CHTSettings getSavedInt:@"solveDetailDisplay"];
                    [solveDetailSegment setSelectedSegmentIndex:detail];
                    cell.accessoryView = solveDetailSegment;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    [cell.detailTextLabel setText:@""];
                }
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    cell.textLabel.font = [CHTTheme font:FONT_REGULAR iphoneSize:18.0f ipadSize:18.0f];
    cell.detailTextLabel.font = [CHTTheme font:FONT_LIGHT iphoneSize:13.0f ipadSize:13.0f];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [CHTUtil getLocalizedString:@"Timing"];
        case 1:
            return [CHTUtil getLocalizedString:@"Stats"];
        default:
            return @"";
            break;
    }
}

- (IBAction)freezeTimeSliderChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    int progressAsInt = (int)roundf(slider.value);
    fTime.text = [NSString stringWithFormat:@"%0.1f s", (double)progressAsInt*0.01];
    if ([fTime.text isEqualToString:@"0.0 s"]) {
        fTime.text = [fTime.text stringByAppendingString:[CHTUtil getLocalizedString:@"no other gesture"]];
    }
    [CHTSettings saveInt:progressAsInt forKey:@"freezeTime"];
}

- (IBAction)wcaSwitchAction:(id)sender {
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    switch (switchButton.tag) {
        case 1:
            if (isButtonOn) {
                [CHTSettings saveBool:YES forKey:@"wcaInspection"];
            }else {
                [CHTSettings saveBool:NO forKey:@"wcaInspection"];
            }
            break;
        case 2:
            
            break;
        default:
            break;
    }
}

- (IBAction)solveOrderSegmentChange:(id)sender {
    UISegmentedControl *segCtrl = (UISegmentedControl *)sender;
    [CHTSettings saveInt:segCtrl.selectedSegmentIndex forKey:@"solveOrder"];
}

- (IBAction)solveDetailSegmentChange:(id)sender {
    UISegmentedControl *segCtrl = (UISegmentedControl *)sender;
    [CHTSettings saveInt:segCtrl.selectedSegmentIndex forKey:@"solveDetailDisplay"];
}
@end
