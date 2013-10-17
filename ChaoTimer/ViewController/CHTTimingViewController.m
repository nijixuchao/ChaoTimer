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
#import "CHTScramblePickerView.h"
#import "CHTScrambler.h"
#import <mach/mach_time.h>

#define TAG_ALERT_CHANGE_SCRAMBLE_TYPE 4

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
BOOL wcaInspection;
BOOL inspectionBegin;
BOOL plus2;
int scrType;
int scrSubType;
int oldScrType;
int oldScrSubType;

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
    UIApplication *myApp = [UIApplication sharedApplication];
    [myApp setIdleTimerDisabled:YES];
    [myApp setStatusBarHidden:NO withAnimation:NO];
    
    longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(startTimer:)];
    [longPressGesture setAllowableMovement:50];
    [self setFreezeTime];
    [self.view addGestureRecognizer:longPressGesture];
    [self setupGestures];
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
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)  name:UIDeviceOrientationDidChangeNotification  object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setFreezeTime];
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
}


- (void)viewWillDisappear:(BOOL)animated {
    [CHTSessionManager saveSession:self.session];
    [self performSelector:@selector(stopTimer)];
    [super viewWillDisappear:animated];
}

- (void)orientationChanged:(NSNotification *)notification{
    NSLog(@"orientation changed");
    [self.pickerView close];
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

- (void) setFreezeTime
{
    [longPressGesture setMinimumPressDuration:[CHTSettings getFreezeTime] * 0.01];
}

- (void) setupGestures
{
    UISwipeGestureRecognizer *swipeGestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(deleteLastSolve:)];
    [swipeGestureLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [swipeGestureLeft requireGestureRecognizerToFail:longPressGesture];
    [self.view addGestureRecognizer:swipeGestureLeft];
    
    UISwipeGestureRecognizer *swipeGestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(getNewScramble:)];
    [swipeGestureRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [swipeGestureRight requireGestureRecognizerToFail:longPressGesture];
    [self.view addGestureRecognizer:swipeGestureRight];
    
    //UISwipeGestureRecognizer *swipeGestureUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(displayScrambleImage:)];
    UISwipeGestureRecognizer *swipeGestureUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(resetTimerStatus:)];
    [swipeGestureUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [swipeGestureUp requireGestureRecognizerToFail:longPressGesture];
    [self.view addGestureRecognizer:swipeGestureUp];
    
    UISwipeGestureRecognizer *swipeGestureDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(resetTimerStatus:)];
    [swipeGestureDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [swipeGestureDown requireGestureRecognizerToFail:longPressGesture];
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
    //NSLog(@"touch begin.");
    [super touchesBegan:touches withEvent:event];
    if  (self.timerStatus == TIMER_IDLE) {
        [self.timeLabel setTextColor:[UIColor redColor]];
        self.timerStatus = TIMER_FREEZE;
    } else if(self.timerStatus == TIMER_TIMING){
        [self performSelector:@selector(stopTimer)];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    if (self.timerStatus == TIMER_FREEZE) {
        self.timerStatus = TIMER_IDLE;
        [self.timeLabel setTextColor:self.timerTheme.textColor];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    //NSLog(@"touch cancel.");
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
    //if (!wcaInspection) {
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
                //[self hideTabBar:YES];
            }
        }
    /*}
    else {
        if (inspectionBegin) {
            if (sender.state == UIGestureRecognizerStateBegan) {
                if (self.timerStatus == 5) {
                    self.timerDisplay.textColor = [UIColor greenColor];
                    self.timerStatus = 2;
                }
            }
            if (sender.state == UIGestureRecognizerStateCancelled) {
                self.timerDisplay.textColor = [UIColor redColor];
                self.timerStatus = 5;
            }
            else if (sender.state == UIGestureRecognizerStateEnded) {
                if (self.timerStatus == 2) {
                    self.timerDisplay.textColor = self.timerTheme.textColor;
                    self.timerDisplay.text = @"0.000";
                    self.timeWhenTimerStart = mach_absolute_time();
                    self.time = 0;
                    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
                    self.timerStatus = 3;
                    inspectionBegin = NO;
                    //[self hideTabBar:YES];
                }
            }
        }
        else {
            if (sender.state == UIGestureRecognizerStateBegan) {
                NSLog(@"start touch began.");
                if (self.timerStatus == 1) {
                    self.timerDisplay.textColor = [UIColor greenColor];
                    self.timerStatus = 2;
                }
            }
            if (sender.state == UIGestureRecognizerStateCancelled) {
                NSLog(@"start touch cancel.");
                self.timerDisplay.textColor = self.timerTheme.textColor;
                self.timerStatus = 0;
            }
            else if (sender.state == UIGestureRecognizerStateEnded) {
                NSLog(@"start touch end.");
                if (self.timerStatus == 2) {
                    self.timerDisplay.textColor = self.timerTheme.textColor;
                    self.timerDisplay.text = @"15";
                    self.inspectionTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateInspectionTime) userInfo:nil repeats:YES];
                    self.timerStatus = 5;
                    inspectionBegin = YES;
                    //[self hideTabBar:YES];
                }
            }
            
        }
        
    }*/
}

- (void)stopTimer{
    if (self.timerStatus == TIMER_TIMING) {
        [self.myTimer invalidate];
        //[self.inspectionTimer invalidate];
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
        /*
        self.thisScramble = self.nextScramble;
        //self.thisScramble = [self.scrambler generateScrambleString:self.scrambleType];
        NSLog(@"this: %@", self.thisScramble);
        self.scrambleDisplay.text = self.thisScramble;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        solvedTimes++;
        BOOL ifRated = [defaults boolForKey:@"ifRated"];
        if (solvedTimes >= 100) {
            solvedTimes = 0;
            if (!ifRated) {
                UIAlertView *rateAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"rateTitle", NULL) message:NSLocalizedString(@"rateBody", NULL) delegate:self cancelButtonTitle:NSLocalizedString(@"remind later", NULL) otherButtonTitles:NSLocalizedString(@"remind now", NULL), NSLocalizedString(@"never remind", NULL) , nil];
                [rateAlert setTag:6];
                [rateAlert show];
            }
        }
        NSLog(@"times: %d", solvedTimes);
        [defaults setInteger:solvedTimes forKey:@"solvedTimes"];
        NSLog(@"times get: %d", [defaults integerForKey:@"solvedTimes"]);
        [self performSelector:@selector(generateNextScramble) withObject:nil afterDelay:0.1];
        //self.thisScramble = [self.scrambler generateScrambleString:self.scrambleType];
        //self.scrambleDisplay.text = self.thisScramble;
        //[self hideTabBar:NO];
         */
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
            [deleteLastTimeAlert setTag:1];
            [deleteLastTimeAlert show];
        }
    }
}

- (IBAction)resetSession:(UITapGestureRecognizer *)tapGesture{
    NSLog(@"Clear Timer.");
    if (self.timerStatus != TIMER_TIMING && self.timerStatus != TIMER_INSPECT && self.session.numberOfSolves > 0) {
        UIAlertView *clearTimeAlert = [[UIAlertView alloc] initWithTitle:[CHTUtil getLocalizedString:@"reset session"] message:[CHTUtil getLocalizedString:@"sure?"] delegate:self cancelButtonTitle:[CHTUtil getLocalizedString:@"no"]otherButtonTitles:[CHTUtil getLocalizedString:@"yes"], nil];
        [clearTimeAlert setTag:2];
        [clearTimeAlert show];
    }
}

- (IBAction)addPenalty:(UITapGestureRecognizer *)tapGesture {
    NSLog(@"add penalty.");
    if (self.session.numberOfSolves > 0 && ![self.timeLabel.text isEqualToString:@"Ready"] && self.timerStatus != TIMER_TIMING && self.timerStatus != TIMER_INSPECT && self.session.lastSolve.timeBeforePenalty != 2147483647) {
        UIAlertView *addPenaltyAlert = [[UIAlertView alloc] initWithTitle:[CHTUtil getLocalizedString:@"penalty"] message:[CHTUtil getLocalizedString:@"this time was"] delegate:self cancelButtonTitle:[CHTUtil getLocalizedString:@"cancel"] otherButtonTitles:@"+2", @"DNF", [CHTUtil getLocalizedString:@"no penalty"] , nil];
        [addPenaltyAlert setTag:3];
        [addPenaltyAlert show];
    }
}

- (IBAction)chooseScrambleType:(id)sender {
    NSLog(@"Choose Scramble Type.");
    if (self.timerStatus != TIMER_TIMING && self.timerStatus != TIMER_INSPECT) {
        pickerView = [[CHTScramblePickerView alloc] init];
        [pickerView setDelegate:self];
        [pickerView setTag:TAG_ALERT_CHANGE_SCRAMBLE_TYPE];
        [pickerView show];
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
        case 1:
            // delete last time
            if (buttonIndex == 1) {
                [self.session deleteLastSolve];
                self.timeLabel.text = @"Ready";
            }
            [CHTSessionManager saveSession:self.session];
            break;
        case 2:
            // clear session
            if (buttonIndex == 1) {
                [self.session clear];
                self.timeLabel.text = @"Ready";
            }
            [CHTSessionManager saveSession:self.session];
            break;
        case 3:
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
        case 5:
            switch (buttonIndex) {
                case 1:
                {
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setBool:YES forKey:@"ifRated"];
                    NSString *str = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%d", 537516001];
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
        default:
            break;
    }
    self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", self.session.numberOfSolves];
}

@end
