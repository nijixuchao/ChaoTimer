//
//  CHTTimingViewController.m
//  ChaoTimer
//
//  Created by Jichao Li on 8/6/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import "CHTTimingViewController.h"
#import "CHTSettings.h"
#import "CHTSession.h"
#import "CHTScramble.h"
#import "CHTSolve.h"
#import "CHTSessionManager.h"
#import "CHTUtil.h"
#import "CHTTheme.h"
#import "CHTScrambler.h"
#import <mach/mach_time.h>
#import <CoreMotion/CoreMotion.h>

#define TAG_ALERT_DELETE_LAST_SOLVE 1
#define TAG_ALERT_CLEAR_SESSION 2
#define TAG_ALERT_ADD_PANELTY 3
#define TAG_ALERT_CHANGE_SCRAMBLE_TYPE 4
#define TAG_ALERT_RATE_ME 5
#define TAG_ALERT_ADD_NEW_SOLVE 6

@interface CHTTimingViewController ()
@property (nonatomic) TimerStatus timerStatus;
@property (nonatomic) int time;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic) long long timeWhenTimerStart;
@property (nonatomic, strong) CHTSession *session;
@property (nonatomic, strong) CHTTheme *timerTheme;
@property (nonatomic, strong) CHTScrambler *scrambler;
@property (nonatomic, strong) CHTScramble *thisScramble;
@property (nonatomic, strong) CHTScramble *nextScramble;
@property (nonatomic, strong) CHTScramblePickerView *pickerView;
@property NSTimer *inspectionTimer;
@property NSTimer *inspectionOverTimeTimer;
@property (strong, nonatomic) CMMotionManager *motionManager;
@end

@implementation CHTTimingViewController
@synthesize longPressGesture;
@synthesize timerStatus;
@synthesize timeWhenTimerStart;
@synthesize session = _session;
@synthesize timerTheme;
@synthesize scrambler = _scrambler;
@synthesize thisScramble = _thisScramble;
@synthesize nextScramble = _nextScramble;
@synthesize pickerView;
@synthesize inspectionTimer;
@synthesize inspectionOverTimeTimer;
@synthesize motionManager;

BOOL wcaInspection;
BOOL inspectionBegin;
BOOL plus2;
int scrType;
int scrSubType;
int oldScrType;
int oldScrSubType;
int solvedTimes;
int threshold;
BOOL knockToStop;

- (CHTSession *) session {
    if (!_session) {
        _session = [[CHTSessionManager load] loadCurrentSession];;
    }
    return _session;
}

- (CHTScrambler *)scrambler {
    if(!_scrambler)
        _scrambler = [[CHTScrambler alloc] init];
    return _scrambler;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [CHTSettings initUserDefaults];
    UIApplication *myApp = [UIApplication sharedApplication];
    [myApp setIdleTimerDisabled:YES];
    [myApp setStatusBarHidden:NO withAnimation:NO];
    
    self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(startTimer:)];
    [self.longPressGesture setAllowableMovement:50];
    [self.longPressGesture setMinimumPressDuration:[CHTSettings getFreezeTime] * 0.01];
    [self.view addGestureRecognizer:self.longPressGesture];
    [self setupGestures];
    self.timerStatus = TIMER_IDLE;
    [[[[[self tabBarController] tabBar] items] objectAtIndex:0] setTitle:[CHTUtil getLocalizedString:@"Timing"]];
    [[[[[self tabBarController] tabBar] items] objectAtIndex:1] setTitle:[CHTUtil getLocalizedString:@"Stats"]];
    [[[[[self tabBarController] tabBar] items] objectAtIndex:2] setTitle:[CHTUtil getLocalizedString:@"Help"]];
    [[[[[self tabBarController] tabBar] items] objectAtIndex:3] setTitle:[CHTUtil getLocalizedString:@"More"]];
    
    self.session = [[CHTSessionManager load] loadCurrentSession];
    scrType = self.session.currentType;
    scrSubType = self.session.currentSubType;
    oldScrType = scrType;
    oldScrSubType = scrSubType;
    NSLog(@"Current scramble type: %d, %d", scrType, scrSubType);
    [self.scrambler initSq1];
    [self changeScramble];
    [self.scrambleLabel setFont:[CHTTheme font:FONT_LIGHT iphoneSize:20.0f ipadSize:40.0f]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.longPressGesture setMinimumPressDuration:[CHTSettings getFreezeTime] * 0.01];
    if ([CHTUtil versionUpdateds]) {
        UIAlertView *updateAlert = [[UIAlertView alloc] initWithTitle:[CHTUtil getLocalizedString:@"appUpdated"] message:[CHTUtil getLocalizedString:@"appUpdatedDetail"] delegate:self cancelButtonTitle:[CHTUtil getLocalizedString:@"OK" ] otherButtonTitles:nil];
        [updateAlert show];
        [[self.tabBarController.tabBar.items objectAtIndex:2] setBadgeValue:[CHTUtil getLocalizedString:@"new"]];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"view will appear");
    [super viewWillAppear:animated];
    [self setTheme];
    self.session = [[CHTSessionManager load] loadCurrentSession];
    self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", self.session.numberOfSolves];
    if (self.session.currentType != oldScrType || self.session.currentSubType != oldScrSubType) {
        [self changeScramble];
        oldScrType = self.session.currentType;
        oldScrSubType = self.session.currentSubType;
    }
    wcaInspection = [CHTSettings boolForKey:@"wcaInspection"];
    solvedTimes = [CHTSettings intForKey:@"solvedTimes"];
    knockToStop = [CHTSettings boolForKey:@"knockToStop"];
    threshold = [CHTSettings intForKey:@"knockSensitivity"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [CHTSessionManager saveSession:self.session];
    [self performSelector:@selector(stopTimer)];
    [super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setTheme {
    self.timerTheme = [CHTTheme getTimerTheme];
    [self.timerTheme setNavigationControllerTheme];
    [self.view setBackgroundColor:self.timerTheme.backgroundColor];
    [self.tabBarController.tabBar setBarTintColor: self.timerTheme.tabBarColor];
    [self.scrambleLabel setTextColor: self.timerTheme.textColor];
    [self.timeLabel setTextColor:self.timerTheme.textColor];
}

- (void) startCoreMotion
{
    if (knockToStop) {
        self.motionManager = [[CMMotionManager alloc] init];
        self.motionManager.gyroUpdateInterval = 0.01;

        int tolerance = 150 - threshold;
        NSLog(@"threshold: %d", threshold);
        [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue]
                                        withHandler:^(CMGyroData *gyroData, NSError *error) {
                                            [self noticeRotationData:gyroData.rotationRate tolerance:(int)tolerance];
                                        }];
    }
}

- (void) stopCoreMotion
{
    if (self.motionManager) {
        [self.motionManager stopGyroUpdates];
    }
}

-(void)noticeRotationData:(CMRotationRate)rotation tolerance:(int)tolerance
{
    int value = abs(rotation.x * 1000) + abs(rotation.y * 1000) + abs(rotation.z * 1000);
    if (value > tolerance) {
        NSLog(@"value: %d, thrd: %d, rotX: %@, rotY: %@, rotZ: %@", value, tolerance, [NSString stringWithFormat:@" %fg",rotation.x], [NSString stringWithFormat:@" %fg",rotation.y], [NSString stringWithFormat:@" %fg",rotation.z]);
        [self stopTimer];
    }
}

- (void) setupGestures
{
    UISwipeGestureRecognizer *swipeGestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(deleteLastSolve:)];
    [swipeGestureLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeGestureLeft requireGestureRecognizerToFail:self.longPressGesture];
    [self.view addGestureRecognizer:swipeGestureLeft];
    
    UISwipeGestureRecognizer *swipeGestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(getNewScramble:)];
    [swipeGestureRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [swipeGestureRight requireGestureRecognizerToFail:self.longPressGesture];
    [self.view addGestureRecognizer:swipeGestureRight];
    
    //UISwipeGestureRecognizer *swipeGestureUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(displayScrambleImage:)];
    UISwipeGestureRecognizer *swipeGestureUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(resetTimerStatus:)];
    [swipeGestureUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [swipeGestureUp requireGestureRecognizerToFail:self.longPressGesture];
    [self.view addGestureRecognizer:swipeGestureUp];
    
    UISwipeGestureRecognizer *swipeGestureDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(manuallyAddNewSolve:)];
    [swipeGestureDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [swipeGestureDown requireGestureRecognizerToFail:self.longPressGesture];
    [self.view addGestureRecognizer:swipeGestureDown];
    
    UITapGestureRecognizer *singleFingerDoubleTaps = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addPenalty:)];
    [singleFingerDoubleTaps setNumberOfTapsRequired:2];
    [singleFingerDoubleTaps setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:singleFingerDoubleTaps];
    
    UITapGestureRecognizer *twoFingersDoubleTaps = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetSession:)];
    [twoFingersDoubleTaps setNumberOfTapsRequired:2];
    [twoFingersDoubleTaps setNumberOfTouchesRequired:2];
    [self.view addGestureRecognizer:twoFingersDoubleTaps];
    
    UISwipeGestureRecognizer *twoFingersSwipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(chooseScrambleType:)];
    [twoFingersSwipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [twoFingersSwipeUp setNumberOfTouchesRequired:2];
    [self.view addGestureRecognizer:twoFingersSwipeUp];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touch begin.");
    [super touchesBegan:touches withEvent:event];
    if  (self.timerStatus == TIMER_IDLE) {
        [self.timeLabel setTextColor:[UIColor redColor]];
        self.timerStatus = TIMER_FREEZE;
    } else if(self.timerStatus == TIMER_TIMING){
        [self performSelector:@selector(stopTimer)];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touch ended.");
    [super touchesEnded:touches withEvent:event];
    if (self.timerStatus == TIMER_FREEZE) {
        self.timerStatus = TIMER_IDLE;
        [self.timeLabel setTextColor:self.timerTheme.textColor];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touch cancel.");
    [super touchesBegan:touches withEvent:event];
    if  (self.timerStatus == TIMER_FREEZE) {
        self.timerStatus = TIMER_IDLE;
        [self.timeLabel setTextColor:self.timerTheme.textColor];
    }
}

- (void)updateTime {
    long long timeNow = mach_absolute_time();
    mach_timebase_info_data_t info;
    mach_timebase_info(&info);
    self.time = (timeNow - self.timeWhenTimerStart) * info.numer / info.denom / 1000000;
    NSString *timeToDisplay = [CHTUtil convertTimeFromMsecondToString:self.time];
    [self.timeLabel setText:timeToDisplay];
}

- (IBAction)startTimer:(UILongPressGestureRecognizer *)sender {
    if (!wcaInspection) {
        if (sender.state == UIGestureRecognizerStateBegan) {
            if (self.timerStatus == TIMER_FREEZE) {
                [self.timeLabel setTextColor:[UIColor greenColor]];
                self.timerStatus = TIMER_READY;
            }
        } else if (sender.state == UIGestureRecognizerStateCancelled) {
            [self.timeLabel setTextColor:self.timerTheme.textColor];
            self.timerStatus = TIMER_IDLE;
        }
        else if (sender.state == UIGestureRecognizerStateEnded) {
            if (self.timerStatus == TIMER_READY) {
                [self.timeLabel setTextColor:self.timerTheme.textColor];
                [self.timeLabel setText: @"0.000"];
                self.timeWhenTimerStart = mach_absolute_time();
                self.time = 0;
                self.myTimer = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
                self.timerStatus = TIMER_TIMING;
                [self startCoreMotion];
                //[self hideTabBar:YES];
            }
        }
    }
    else {
        if (inspectionBegin) {
            if (sender.state == UIGestureRecognizerStateBegan) {
                if (self.timerStatus == TIMER_INSPECT) {
                    self.timeLabel.textColor = [UIColor greenColor];
                    self.timerStatus = TIMER_READY;
                }
            }
            if (sender.state == UIGestureRecognizerStateCancelled) {
                self.timeLabel.textColor = [UIColor redColor];
                self.timerStatus = TIMER_INSPECT;
            }
            else if (sender.state == UIGestureRecognizerStateEnded) {
                if (self.timerStatus == TIMER_READY) {
                    self.timeLabel.textColor = self.timerTheme.textColor;
                    self.timeLabel.text = @"0.000";
                    self.timeWhenTimerStart = mach_absolute_time();
                    self.time = 0;
                    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
                    self.timerStatus = TIMER_TIMING;
                    inspectionBegin = NO;
                    [self startCoreMotion];
                    //[self hideTabBar:YES];
                }
            }
        }
        else {
            if (sender.state == UIGestureRecognizerStateBegan) {
                NSLog(@"start touch began.");
                if (self.timerStatus == TIMER_FREEZE) {
                    self.timeLabel.textColor = [UIColor greenColor];
                    self.timerStatus = TIMER_READY;
                }
            }
            if (sender.state == UIGestureRecognizerStateCancelled) {
                NSLog(@"start touch cancel.");
                self.timeLabel.textColor = self.timerTheme.textColor;
                self.timerStatus = TIMER_IDLE;
            }
            else if (sender.state == UIGestureRecognizerStateEnded) {
                NSLog(@"start touch end.");
                if (self.timerStatus == TIMER_READY) {
                    self.timeLabel.textColor = self.timerTheme.textColor;
                    self.timeLabel.text = @"15";
                    self.inspectionTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateInspectionTime) userInfo:nil repeats:YES];
                    self.timerStatus = TIMER_INSPECT;
                    inspectionBegin = YES;
                    //[self hideTabBar:YES];
                }
            }
            
        }
        
    }
}

- (void)updateInspectionTime{
    self.timeLabel.text = [NSString stringWithFormat:@"%d", ([self.timeLabel.text intValue] - 1)];
    if ([self.timeLabel.text isEqualToString:@"1"]) {
        [self.inspectionTimer invalidate];
        self.inspectionOverTimeTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(updateInspectionOverTimeTimer) userInfo:nil repeats:YES];
    }
}

- (void)updateInspectionOverTimeTimer {
    if ([self.timeLabel.text isEqualToString:@"1"]) {
        self.timeLabel.text = @"+2";
        plus2 = YES;
        return;
    }
    if ([self.timeLabel.text isEqualToString:@"+2"]) {
        plus2 = NO;
        self.timeLabel.text = @"DNF";
        [self.inspectionOverTimeTimer invalidate];
        self.timerStatus = TIMER_IDLE;
        inspectionBegin = NO;
        [self.session addSolve:0 withPenalty:PENALTY_DNF scramble:self.thisScramble];
        [CHTSessionManager saveSession:self.session];
        self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", self.session.numberOfSolves];
        [self displayNextScramble];
    }
}

- (void)stopTimer{
    if (self.timerStatus == TIMER_TIMING) {
        if (self.time == 0)
            return;
        [self.myTimer invalidate];
        [self.inspectionTimer invalidate];
        self.timerStatus = TIMER_IDLE;
        inspectionBegin = NO;
        if (!plus2) {
            [self.session addSolve:self.time withPenalty:PENALTY_NO_PENALTY scramble:self.thisScramble];
        }
        else {
            [self.session addSolve:self.time withPenalty:PENALTY_PLUS_2 scramble:self.thisScramble];
            plus2 = NO;
            self.timeLabel.text = [self.session.lastSolve toString];
        }
        [CHTSessionManager saveSession:self.session];
        self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", self.session.numberOfSolves];
        [self displayNextScramble];
        [self stopCoreMotion];
        [self checkRated];
    }
}

- (IBAction)resetTimerStatus:(id)sender {
    NSLog(@"reset!");
    if  (!wcaInspection && timerStatus != TIMER_TIMING) {
        self.timeLabel.textColor = timerTheme.textColor;
        self.timerStatus = TIMER_IDLE;
    }
}

- (IBAction)deleteLastSolve:(UISwipeGestureRecognizer *)swipeGesture {
    NSLog(@"swipe left.");
    if (self.timerStatus != TIMER_TIMING && self.timerStatus != TIMER_INSPECT && self.session.numberOfSolves > 0) {
        if (swipeGesture.direction == UISwipeGestureRecognizerDirectionLeft) {
            UIAlertView *deleteLastTimeAlert = [[UIAlertView alloc] initWithTitle:[CHTUtil getLocalizedString:@"delete last"] message:[CHTUtil getLocalizedString:@"sure?"] delegate:self cancelButtonTitle:[CHTUtil getLocalizedString:@"no"]otherButtonTitles:[CHTUtil getLocalizedString:@"yes"], nil];
            [deleteLastTimeAlert setTag:TAG_ALERT_DELETE_LAST_SOLVE];
            [deleteLastTimeAlert show];
        }
    }
}

- (IBAction)resetSession:(UITapGestureRecognizer *)tapGesture{
    NSLog(@"Clear Timer.");
    if (self.timerStatus != TIMER_TIMING && self.timerStatus != TIMER_INSPECT && self.session.numberOfSolves > 0) {
        UIAlertView *clearTimeAlert = [[UIAlertView alloc] initWithTitle:[CHTUtil getLocalizedString:@"reset session"] message:[CHTUtil getLocalizedString:@"sure?"] delegate:self cancelButtonTitle:[CHTUtil getLocalizedString:@"no"]otherButtonTitles:[CHTUtil getLocalizedString:@"yes"], nil];
        [clearTimeAlert setTag:TAG_ALERT_CLEAR_SESSION];
        [clearTimeAlert show];
    }
}

- (IBAction)addPenalty:(UITapGestureRecognizer *)tapGesture {
    NSLog(@"add penalty.");
    if (self.session.numberOfSolves > 0 && ![self.timeLabel.text isEqualToString:@"Ready"] && self.timerStatus != TIMER_TIMING && self.timerStatus != TIMER_INSPECT && self.session.lastSolve.timeBeforePenalty != 2147483647) {
        UIAlertView *addPenaltyAlert = [[UIAlertView alloc] initWithTitle:[CHTUtil getLocalizedString:@"penalty"] message:[CHTUtil getLocalizedString:@"this time was"] delegate:self cancelButtonTitle:[CHTUtil getLocalizedString:@"cancel"] otherButtonTitles:@"+2", @"DNF", [CHTUtil getLocalizedString:@"no penalty"] , nil];
        [addPenaltyAlert setTag:TAG_ALERT_ADD_PANELTY];
        [addPenaltyAlert show];
    }
}

- (IBAction)chooseScrambleType:(id)sender {
    NSLog(@"Choose Scramble Type.");
    if (self.timerStatus != TIMER_TIMING && self.timerStatus != TIMER_INSPECT) {
        pickerView = [[CHTScramblePickerView alloc] initWithPickerView];
        [pickerView setDelegate:self];
        [pickerView setTag:TAG_ALERT_CHANGE_SCRAMBLE_TYPE];
        [pickerView show];
    }
}

- (IBAction)manuallyAddNewSolve:(id)sender {
    NSLog(@"Manually Add New Solve");
    if (self.timerStatus != TIMER_TIMING && self.timerStatus != TIMER_INSPECT) {
        UIAlertView *manuallyAddAlert = [[UIAlertView alloc] initWithTitle:[CHTUtil getLocalizedString:@"manuallyAdd"] message:[CHTUtil getLocalizedString:@"originalTime"] delegate:self cancelButtonTitle:[CHTUtil getLocalizedString:@"cancel"] otherButtonTitles:[CHTUtil getLocalizedString:@"done"], nil];
        [manuallyAddAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        UITextField *timeInput = [manuallyAddAlert textFieldAtIndex:0];
        [timeInput setKeyboardType:UIKeyboardTypeDecimalPad];
        [manuallyAddAlert setTag:TAG_ALERT_ADD_NEW_SOLVE];
        [manuallyAddAlert show];
    }
    
}

/* Delegate of CustomIOS7AlertView*/
- (void)customIOS7dialogButtonTouchUpInside: (CHTScramblePickerView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //NSLog(@"Button Clicked! %d, %d", buttonIndex, [alertView tag]);
    [alertView close];
    if (buttonIndex == 1) {
        scrType = alertView.selectedType;
        scrSubType = alertView.selectedSubType;
        self.session.currentType = alertView.selectedType;
        self.session.currentSubType = alertView.selectedSubType;
        oldScrType = scrType;
        oldScrSubType = scrSubType;
        [self changeScramble];
        [CHTSessionManager saveSession:self.session];
        NSLog(@"choose scramble index: %d, %d", self.session.currentType, self.session.currentSubType);
    }
}

- (void)changeScramble{
    self.nextScramble = [CHTScramble getNewScrambleByScrambler:self.scrambler type:self.session.currentType subType:self.session.currentSubType];
    [self displayNextScramble];
}

- (void)displayNextScramble {
    self.thisScramble = self.nextScramble;
    self.scrambleLabel.text = self.thisScramble.scramble;
    NSLog(@"this scramble: %@", self.thisScramble.scramble);
    [self performSelector:@selector(generateNextScramble) withObject:nil afterDelay:1];
}

- (IBAction)getNewScramble:(id)sender {
    if (self.timerStatus != TIMER_TIMING && self.timerStatus != TIMER_INSPECT) {
        [self displayNextScramble];
    }
}

- (void)generateNextScramble {
    self.nextScramble = [CHTScramble getNewScrambleByScrambler:self.scrambler type:self.session.currentType subType:self.session.currentSubType];
    NSLog(@"next scramble: %@", self.nextScramble.scramble);
}

- (void)alertView:(UIAlertView *)uiAlertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (uiAlertView.tag) {
        case TAG_ALERT_DELETE_LAST_SOLVE:
            // delete last time
            if (buttonIndex == 1) {
                [self.session deleteLastSolve];
                self.timeLabel.text = @"Ready";
            }
            [CHTSessionManager saveSession:self.session];
            break;
        case TAG_ALERT_CLEAR_SESSION:
            // clear session
            if (buttonIndex == 1) {
                [self.session clear];
                self.timeLabel.text = @"Ready";
            }
            [CHTSessionManager saveSession:self.session];
            break;
        case TAG_ALERT_ADD_PANELTY:
            // add penalty
            switch (buttonIndex) {
                case 1:
                    [self.session addPenaltyToLastSolve:PENALTY_PLUS_2];
                    self.timeLabel.text = [self.session.lastSolve toString];
                    [CHTSessionManager saveSession:self.session];
                    break;
                case 2:
                    [self.session addPenaltyToLastSolve:PENALTY_DNF];
                    self.timeLabel.text = [self.session.lastSolve toString];
                    [CHTSessionManager saveSession:self.session];
                    break;
                case 3:
                    [self.session addPenaltyToLastSolve:PENALTY_NO_PENALTY];
                    self.timeLabel.text = [self.session.lastSolve toString];
                    [CHTSessionManager saveSession:self.session];
                    break;
                default:
                    break;
            }
            break;
        case TAG_ALERT_CHANGE_SCRAMBLE_TYPE:
            //choose scramble type
            if (buttonIndex == 1) {
                NSLog(@"new Scramble");
            }
            
            break;
        case TAG_ALERT_RATE_ME:
            switch (buttonIndex) {
                case 1:
                {
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setBool:YES forKey:@"ifRated"];
                    NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%d", 537516001];
                    NSLog(@"URL string:%@",str);
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
                    
                }
                    break;
                case 2:
                {
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setBool:YES forKey:@"ifRated"];
                }
                    break;
                default:
                    break;
            }
            break;
        case TAG_ALERT_ADD_NEW_SOLVE:
        {
            if (buttonIndex == 1) {
                NSString *text = [uiAlertView textFieldAtIndex:0].text;
                NSNumberFormatter * nf = [[NSNumberFormatter alloc] init];
                [nf setNumberStyle:NSNumberFormatterDecimalStyle];
                NSArray* nums = [text componentsSeparatedByString:@"."];
                if (nums.count > 2) {
                    text = [NSString stringWithFormat:@"%@.%@", (NSString *)[nums objectAtIndex:0], (NSString *)[nums objectAtIndex:1]];
                }
                NSNumber * myNumber = [nf numberFromString:text];
                NSLog(@"%f", [myNumber doubleValue]);
                int time = (int)([myNumber doubleValue] * 1000);
                [self.session addSolve:time withPenalty:PENALTY_NO_PENALTY scramble:self.thisScramble];
                [CHTSessionManager saveSession:self.session];
                self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", self.session.numberOfSolves];
                self.timeLabel.text = [[self.session lastSolve] toString];
                [self displayNextScramble];
                [self checkRated];
                
            }
        }
            break;
        default:
            break;
    }
    self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", self.session.numberOfSolves];
}

- (void) checkRated {
    solvedTimes++;
    BOOL ifRated = [CHTSettings boolForKey:@"ifRated"];
    if (solvedTimes >= 100) {
        solvedTimes = 0;
        if (!ifRated) {
            UIAlertView *rateAlert = [[UIAlertView alloc]
                                      initWithTitle:[CHTUtil getLocalizedString:@"rateTitle" ]
                                      message:[CHTUtil getLocalizedString:@"rateBody"]
                                      delegate:self
                                      cancelButtonTitle:[CHTUtil getLocalizedString:@"remind later"]
                                      otherButtonTitles:[CHTUtil getLocalizedString:@"remind now"], [CHTUtil getLocalizedString:@"never remind"], nil];
            [rateAlert setTag:TAG_ALERT_RATE_ME];
            [rateAlert show];
        }
    }
    NSLog(@"times: %d", solvedTimes);
    [CHTSettings saveInt:solvedTimes forKey:@"solvedTimes"];
}

@end
