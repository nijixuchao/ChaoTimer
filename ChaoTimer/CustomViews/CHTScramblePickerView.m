//
//  CHTCustomPickerView.m
//  ChaoTimer
//
//  Created by Jichao Li on 10/6/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import "CHTScramblePickerView.h"
#import "CHTScrambler.h"

#define componentCount 2
#define typeComponent 0
#define subsetComponent 1
#define typeComponentWidth 110
#define subsetComponentWidth 150
#define rowHeight 35.0f

@interface CHTScramblePickerView ()

@property (nonatomic, strong) NSDictionary *scrType;
@property (nonatomic, strong) NSArray *types;
@property (nonatomic, strong) NSArray *subsets;
@property (nonatomic, strong) UIPickerView *myPickerView;

@end

@implementation CHTScramblePickerView

@synthesize scrType;
@synthesize types;
@synthesize subsets;
@synthesize myPickerView;
@synthesize selectedType;
@synthesize selectedSubType;

- (id) init {
    self = [self initWithParentView:[UIApplication sharedApplication].keyWindow.subviews.lastObject];
    if (self) {
        [self addPickerView];
        self.buttonTitles = [NSMutableArray arrayWithObjects:[CHTUtil getLocalizedString:@"cancel"], [CHTUtil getLocalizedString:@"done"], nil];
    }
    return self;
}

- (void)addPickerView {
    self.selectedType = 0;
    self.selectedSubType = 0;
    NSBundle *bundle = [NSBundle mainBundle];
    NSURL *plistURL = [bundle URLForResource:@"scrambleTypes" withExtension:@"plist"];
    self.scrType = [NSDictionary dictionaryWithContentsOfURL:plistURL];
    self.types = [CHTScrambler scrambleTypes];
    //self.types = [self.scrType allKeys];
    NSString *select = [self.types objectAtIndex:0];
    self.subsets = [self.scrType objectForKey:select];
    self.myPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 270, 300)];
    self.myPickerView.showsSelectionIndicator = YES;
    self.myPickerView.delegate = self;
    self.myPickerView.dataSource = self;
    self.myPickerView.opaque = YES;
    [self setContainerView:self.myPickerView];

}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return componentCount;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == typeComponent) {
        return [self.types count];
    } else {
        return [self.subsets count];
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *printString;
    if (component == typeComponent) {
        printString = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, typeComponentWidth, 45)];
        printString.text = [self.types objectAtIndex:row];
    } else {
        printString = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, subsetComponentWidth, 45)];
        printString.text = [self.subsets objectAtIndex:row];
    }
    printString.backgroundColor = [UIColor clearColor];
    printString.textAlignment = NSTextAlignmentCenter;
    
    return printString;
}


- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if (component == typeComponent) {
        return typeComponentWidth;
    } else {
        return subsetComponentWidth;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return rowHeight;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == typeComponent) {
        NSString *selType = [types objectAtIndex:row];
        NSArray *array = [scrType objectForKey:selType];
        subsets = array;
        [pickerView selectRow:0 inComponent:subsetComponent animated:YES];
        [pickerView reloadComponent:subsetComponent];
    }
    self.selectedType = [pickerView selectedRowInComponent:typeComponent];
    self.selectedSubType = [pickerView selectedRowInComponent:subsetComponent];
    NSLog(@"scramble type: %d, %d", self.selectedType, self.selectedSubType);
}

@end
