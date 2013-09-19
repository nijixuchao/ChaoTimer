//
//  CHTSolve.m
//  ChaoTimer
//
//  Created by Jichao Li on 8/10/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import "CHTSolve.h"

@interface CHTSolve()

@end

@implementation CHTSolve

@synthesize index;
@synthesize timeStamp;
@synthesize scramble;
@synthesize timeBeforePenalty;
@synthesize timeAfterPenalty;
@synthesize penalty;

- (int) timeAfterPenalty{
    int time = self.timeBeforePenalty;
    if (self.penalty == PENALTY_PLUS_2) {
        time = self.timeBeforePenalty + 2000;
    } else if (self.penalty == PENALTY_DNF) {
        time = INFINITY;
    }
    return time;
}

- (NSString *) toString {
    NSString *str = [self convertTimeFromMsecondToString:timeAfterPenalty];
    if (penalty == PENALTY_PLUS_2) {
        str = [str stringByAppendingString:@"+"];
    } else if (penalty == PENALTY_DNF) {
        str = @"DNF";
    } 
    return str;
}

- (NSString *) toStringWith2DecimalPlaces {
    NSString *str = [self toString];
    return [str substringToIndex:(str.length - 1)];
    
}

- (void) setTime: (int)newTimeBeforePenalty andPenalty: (PenaltyType)newPenalty {
    self.timeStamp = [NSDate date];
    self.timeBeforePenalty = newTimeBeforePenalty;
    self.penalty = newPenalty;
    self.scramble = [[CHTScramble alloc] init];
}

+ (CHTSolve *) newSolveWith: (int)newTime andPenalty:(PenaltyType)newPenalty andScramble: (CHTScramble *)newScramble {
    CHTSolve *newSolve = [[CHTSolve alloc] init];
    [newSolve setTime:newTime andPenalty:newPenalty];
    [newSolve setScramble:newScramble];
    return newSolve;
}

- (NSString *)convertTimeFromMsecondToString: (int)msecond {
    NSString *outputTimeString;
    if (msecond < 1000) {
        outputTimeString = [NSString stringWithFormat:@"0.%03d", msecond];
    } else if (msecond < 60000) {
        int second = msecond * 0.001;
        int msec = msecond % 1000;
        outputTimeString = [NSString stringWithFormat:@"%d.%03d", second, msec];
    } else if (msecond < 3600000) {
        int minute = msecond / 60000;
        int second = (msecond % 60000)/1000;
        int msec = msecond % 1000;
        outputTimeString = [NSString stringWithFormat:@"%d:%02d.%03d", minute, second, msec];
    } else {
        int hour = msecond / 3600000;
        int minute = (msecond % 360000) / 60000;
        int second = (msecond % 60000) / 1000;
        int msec = msecond % 1000;
        outputTimeString = [NSString stringWithFormat:@"%d:%02d:%02d.%03d", hour, minute, second, msec];
    }
    return outputTimeString;
}


@end
