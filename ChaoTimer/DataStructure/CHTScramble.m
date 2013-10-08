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
@synthesize subType;
@synthesize scramble;

+(CHTScramble *) getNewScrambleByType:(NSString *)newType{
    CHTScramble *newScramble = [[CHTScramble alloc] init];
    [newScramble setType:newType];
    [newScramble setScramble:@""];
    return newScramble;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.type forKey:@"scrambleType"];
    [aCoder encodeObject:self.subType forKey:@"scrambleSubType"];
    [aCoder encodeObject:self.scramble  forKey:@"scrambleString"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self == [super init]) {
        self.type =[aDecoder decodeObjectForKey:@"scrambleType"];
        self.subType = [aDecoder decodeObjectForKey:@"scrambleSubType"];
        self.scramble = [aDecoder decodeObjectForKey:@"scrambleString"];
    }
    return self;
}

- (NSString *) getScrambleString {
    return self.scramble;
    //return @"L 3B2 2F' 3L' U' 3B' 3U2 2B2 L' R' 2R' 3B 2R2 R' 3B' 3L' 2F' 2L' L 2B F2 3D' 2U U' R2 2B2 D' 3F' F' 2F' 2B B 3B' 3D2 3U2 2F' 2D' L' 2B2 2R2 2L' D' R 3R D2 2R' 2B 3R 2B D 2R' 2B' 3R' U 2B 2R2 R2 D 3R2 B F' 3B 3D 2U 3U 3L2 F' 3L D U 3D2 3L' 2F2 L' 2F' L' R' F 2R2 2U' 2L' 3B 3F 3U 2D' 2B 2R 3U2 B 2R' U 2U R 3L U 2L 2F2 3B D2 B'";
}

- (NSString *) getScrambleType {
    return @"3x3x3";
}

@end
