//
//  EPSExampleViewModel.m
//  ReactiveTableViewControllerExample
//
//  Created by Peter Stuart on 2/22/14.
//  Copyright (c) 2014 Electric Peel, LLC. All rights reserved.
//

#import "EPSExampleViewModel.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTKeyPathCoding.h>

#import "EPSNote.h"

@interface EPSExampleViewModel ()

@property (nonatomic) NSSet *notes;

@end

@implementation EPSExampleViewModel

- (id)init {
    self = [super init];
    if (self == nil) return nil;
    
    _notes = [NSSet setWithArray:[[@[ @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z" ].rac_sequence
        map:^EPSNote *(NSString *string) {
            EPSNote *note = [EPSNote new];
            note.text = string;
            
            return note;
        }]
        array]];
    _sortAscending = YES;
    
    RAC(self, sortedNotes) = [RACSignal
        combineLatest:@[ RACObserve(self, notes), RACObserve(self, sortAscending) ]
        reduce:^NSArray *(NSSet *objects, NSNumber *sortAscending){
            return [objects sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"text" ascending:sortAscending.boolValue selector:@selector(localizedStandardCompare:)] ]];
        }];
    
    return self;
}

- (void)addNote:(EPSNote *)object {
    self.notes = [self.notes setByAddingObject:object];
}

- (void)removeNote:(EPSNote *)object {
    NSMutableSet *notes = self.notes.mutableCopy;
    [notes removeObject:object];
    self.notes = notes;
}

@end
