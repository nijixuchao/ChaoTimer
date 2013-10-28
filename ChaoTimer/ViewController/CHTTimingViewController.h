//
//  CHTTimingViewController.h
//  ChaoTimer
//
//  Created by Jichao Li on 8/6/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CHTScramblePickerView.h"

typedef enum timerStatus {
    TIMER_IDLE = 0,
    TIMER_FREEZE = 1,
    TIMER_READY = 2,
    TIMER_TIMING = 3,
    TIMER_INSPECT = 4,
} TimerStatus;

@interface CHTTimingViewController : UIViewController<CustomIOS7AlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *scrambleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property NSTimer *myTimer;
@end
