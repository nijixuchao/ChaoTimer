//
//  CHTScramble.m
//  ChaoTimer
//
//  Created by Jichao Li on 8/12/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import "CHTScramble.h"
#import "CHTScrambler.h"

@implementation CHTScramble

@synthesize scrType;
@synthesize scrSubType;
@synthesize scramble;

+(CHTScramble *) getNewScrambleByScrambler:(CHTScrambler *)scrambler type:(int)type subType:(int)subType {
    CHTScramble *newScramble = [[CHTScramble alloc] init];
    [newScramble setTypeAndSubTypeByType:type subset:subType];
    newScramble.scramble = [scrambler getScrStringByType:type subset:subType];
    return newScramble;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.scrType forKey:@"scrambleType"];
    [aCoder encodeObject:self.scrSubType forKey:@"scrambleSubType"];
    [aCoder encodeObject:self.scramble  forKey:@"scrambleString"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self == [super init]) {
        self.scrType =[aDecoder decodeObjectForKey:@"scrambleType"];
        self.scrSubType = [aDecoder decodeObjectForKey:@"scrambleSubType"];
        self.scramble = [aDecoder decodeObjectForKey:@"scrambleString"];
    }
    return self;
}

- (void)setTypeAndSubTypeByType:(int)type subset:(int)subset {
    NSBundle *bundle = [NSBundle mainBundle];
    NSURL *plistURL = [bundle URLForResource:@"scrambleTypes" withExtension:@"plist"];
    NSDictionary *scrTypeDic = [NSDictionary dictionaryWithContentsOfURL:plistURL];
    NSArray *types = [CHTScrambler scrambleTypes];
    NSString *typeStr = [types objectAtIndex:type];
    NSArray *subsets = [scrTypeDic objectForKey:typeStr];
    NSString *subsetStr = [subsets objectAtIndex:subset];
    self.scrType = typeStr;
    self.scrSubType = subsetStr;
}


@end
