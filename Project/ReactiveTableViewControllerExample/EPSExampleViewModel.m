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

@property (nonatomic) NSMutableArray *unusedNotes;
@property (nonatomic) NSSet *notes;

@end

@implementation EPSExampleViewModel

- (id)init {
    self = [super init];
    if (self == nil) return nil;
    
    NSURL *notesURL = [[NSBundle mainBundle] URLForResource:@"words" withExtension:@"txt"];
    NSString *allNotes = [NSString stringWithContentsOfURL:notesURL encoding:NSUTF8StringEncoding error:nil];
    NSArray *noteStrings = [allNotes componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    _unusedNotes = [[[[noteStrings.rac_sequence
        filter:^BOOL(NSString *string) {
            return string.length > 0;
        }]
        map:^EPSNote *(NSString *string) {
            EPSNote *note = [EPSNote new];
            note.text = string;
            
            return note;
        }]
        array]
        mutableCopy];
    
    NSMutableSet *notes = [NSMutableSet new];
    for (NSInteger counter = 0; counter < 10; counter++) {
        EPSNote *note = _unusedNotes[arc4random() % _unusedNotes.count];
        [notes addObject:note];
        [_unusedNotes removeObject:note];
    }
    
    _notes = notes;
    
    _sortAscending = YES;
    
    RAC(self, sortedNotes) = [RACSignal
        combineLatest:@[ RACObserve(self, notes), RACObserve(self, sortAscending) ]
        reduce:^NSArray *(NSSet *objects, NSNumber *sortAscending){
            NSArray *notes = [objects sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"text" ascending:sortAscending.boolValue selector:@selector(localizedStandardCompare:)] ]];
            
            NSArray *allSectionNames = @[ @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z" ];
            NSMutableDictionary *startingSections = [NSMutableDictionary new];
            for (NSString *sectionName in allSectionNames) {
                startingSections[sectionName] = @[];
            }
            
            NSDictionary *sectionsDictionary = [notes.rac_sequence foldLeftWithStart:startingSections reduce:^NSDictionary *(NSDictionary *accumulator, EPSNote *note) {
                NSMutableDictionary *sections = [accumulator mutableCopy];
                
                NSString *sectionName = [[note.text substringToIndex:1] uppercaseString];
                if (sections[sectionName] == nil) {
                    sections[sectionName] = @[];
                }
                
                NSArray *section = sections[sectionName];
                NSArray *newSection = [section arrayByAddingObject:note];
                
                sections[sectionName] = newSection;
                
                return sections;
            }];
            
            NSArray *sectionNames = [[sectionsDictionary allKeys] sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:sortAscending.boolValue selector:@selector(localizedStandardCompare:)] ]];
            NSArray *sections = [[sectionNames.rac_sequence
                map:^NSArray *(NSString *name){
                    return sectionsDictionary[name];
                }]
                array];
            
            return sections;
        }];
        
    return self;
}

- (void)addNote {
    EPSNote *note = self.unusedNotes[arc4random() % self.unusedNotes.count];
    self.notes = [self.notes setByAddingObject:note];
    [self.unusedNotes removeObject:note];
}

- (void)removeNote:(EPSNote *)object {
    NSMutableSet *notes = self.notes.mutableCopy;
    [notes removeObject:object];
    self.notes = notes;
}

- (NSString *)titleForSection:(NSInteger)section {
    NSArray *allSectionNames = @[ @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z" ];
    if (self.sortAscending == NO) {
        allSectionNames = [[allSectionNames reverseObjectEnumerator] allObjects];
    }
    
    return allSectionNames[section];
}

@end
