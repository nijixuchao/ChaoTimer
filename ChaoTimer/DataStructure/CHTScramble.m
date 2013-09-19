//
//  CHTScramble.m
//  ChaoTimer
//
//  Created by Jichao Li on 8/12/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import "CHTScramble.h"

@implementation CHTScramble

@synthesize type;
@synthesize scramble;

+(CHTScramble *) getNewScrambleByType:(NSString *)newType{
    CHTScramble *newScramble = [[CHTScramble alloc] init];
    [newScramble setType:newType];
    [newScramble setScramble:@""];
    return newScramble;
}


@end
