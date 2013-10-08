//
//  CHTScramble.h
//  ChaoTimer
//
//  Created by Jichao Li on 8/12/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHTScramble : NSObject <NSCoding>
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *subType;
@property (nonatomic, strong) NSString *scramble;

+ (CHTScramble *) getNewScrambleByType: (NSString *)newType;
- (NSString *) getScrambleType;
- (NSString *) getScrambleString;
@end
