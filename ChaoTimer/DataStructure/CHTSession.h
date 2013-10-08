//
//  CHTSession.h
//  ChaoTimer
//
//  Created by Jichao Li on 8/10/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHTSolve.h"
#import "CHTUtil.h"

@interface CHTSession : NSObject <NSCoding>
@property (readonly) int numberOfSolves;
@property (readonly) int bestTime;
@property (readonly) int worstTime;
@property (nonatomic, strong) NSString *currentType;
@property (nonatomic, strong) NSString *sessionName;

+ (CHTSession *) initWithDefault;
+ (CHTSession *) initWithName:(NSString *)name;
- (void)addSolve:(int)time withPenalty:(PenaltyType)penalty scramble:(CHTScramble *)scramble;
- (void)addPenaltyToLastSolve: (PenaltyType)penalty;
- (void)deleteLastSolve;
- (CHTSolve *)lastSolve;
- (CHTSolve *)bestSolve;
- (CHTSolve *)worstSolve;
- (CHTSolve *)bestAvgOf: (int)num;
- (CHTSolve *)currentAvgOf: (int)num;
- (CHTSolve *)sessionAvg;
- (CHTSolve *)sessionMean;
- (NSMutableArray *) getBest: (int)solve;
- (NSMutableArray *) getCurrent: (int)solves;
- (NSMutableArray *) getAllSolves;
- (NSString *)numberOfSolvesToString;
- (NSString *)toString: (BOOL)containIndividualTime;
- (void)removeSolveAtIndex: (int)index;
- (void)removeSolve: (CHTSolve *)aSolve;
- (void)clear;
//- (void)save;
//+ (CHTSession *)loadByName:(NSString *)theName;
@end