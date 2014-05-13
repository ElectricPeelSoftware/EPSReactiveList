//
//  EPSChangeObserver.m
//  ReactiveTableViewControllerExample
//
//  Created by Peter Stuart on 5/5/14.
//  Copyright (c) 2014 Electric Peel, LLC. All rights reserved.
//

#import "EPSChangeObserver.h"

#import <ReactiveCocoa/RACEXTScope.h>
#import <ReactiveCocoa/RACEXTKeyPathCoding.h>

@interface EPSChangeObserver ()

@property (nonatomic) NSArray *objects;
@property (nonatomic) id object;
@property (nonatomic) NSString *keyPath;

@end

@implementation EPSChangeObserver

- (id)init {
    self = [super init];
    if (self == nil) return nil;
        
    _changeSignal = [[self rac_valuesAndChangesForKeyPath:@"objects" options:NSKeyValueObservingOptionOld observer:nil]
        map:^RACTuple *(RACTuple *tuple) {
            RACTupleUnpack(NSArray *newObjects, NSDictionary *changeDictionary) = tuple;
            id oldObjects = changeDictionary[NSKeyValueChangeOldKey];
            
            NSArray *oldObjectsArray;
            if (oldObjects == [NSNull null]) oldObjectsArray = @[];
            else oldObjectsArray = oldObjects;

            NSArray *allRowsToRemove = [oldObjectsArray.rac_sequence
                foldLeftWithStart:@[] reduce:^NSArray *(NSArray *accumulator, NSArray *section) {
                    NSArray *rowsToRemove = [[[section.rac_sequence
                        filter:^BOOL(id object) {
                            return [EPSChangeObserver indexPathOfObject:object inSectionsArray:newObjects] == nil;
                        }]
                        map:^NSIndexPath *(id object) {
                            return [EPSChangeObserver indexPathOfObject:object inSectionsArray:oldObjectsArray];
                        }]
                        array];
                    return [accumulator arrayByAddingObjectsFromArray:rowsToRemove];
                }];
            
            NSArray *allRowsToInsert = [newObjects.rac_sequence
                foldLeftWithStart:@[] reduce:^NSArray *(NSArray *accumulator, NSArray *section) {
                    NSArray *rowsToInsert = [[[section.rac_sequence
                        filter:^BOOL(id object) {
                            return [EPSChangeObserver indexPathOfObject:object inSectionsArray:oldObjectsArray] == nil;
                        }]
                        map:^NSIndexPath *(id object) {
                            return [EPSChangeObserver indexPathOfObject:object inSectionsArray:newObjects];
                        }]
                        array];
                    return [accumulator arrayByAddingObjectsFromArray:rowsToInsert];
                }];
            
            /*
            NSDictionary *allRowsToMove = [newObjects.rac_sequence
                foldLeftWithStart:[NSMutableDictionary new] reduce:^NSDictionary *(NSMutableDictionary *accumulator, NSArray *section) {
                    NSArray *objectsToMove = [[section.rac_sequence
                        filter:^BOOL(id object) {
                            return [EPSChangeObserver indexPathOfObject:object inSectionsArray:oldObjectsArray] != nil;
                        }]
                        array];
                    NSMutableDictionary *rowsToMove = [NSMutableDictionary new];
                    for (id object in objectsToMove) {
                        NSIndexPath *oldIndexPath = [EPSChangeObserver indexPathOfObject:object inSectionsArray:oldObjectsArray];
                        NSIndexPath *newIndexPath = [EPSChangeObserver indexPathOfObject:object inSectionsArray:newObjects];
                        
                        if ([oldIndexPath isEqual:newIndexPath] == NO) {
                            rowsToMove[oldIndexPath] = newIndexPath;
                        }
                    }
                    
                    [accumulator addEntriesFromDictionary:rowsToMove];
                    return accumulator;
                }];
            */
            
            return RACTuplePack(allRowsToRemove, allRowsToInsert);
        }];
    
    return self;
}

- (void)setBindingToKeyPath:(NSString *)keyPath onObject:(id)object {
    RAC(self, objects) = [[object rac_valuesForKeyPath:keyPath observer:self]
        map:^NSArray *(NSArray *array) {
            return @[ array ];
        }];
}

- (void)setSectionBindingToKeyPath:(NSString *)keyPath onObject:(id)object {
    RAC(self, objects) = [object rac_valuesForKeyPath:keyPath observer:self];
}

+ (NSIndexPath *)indexPathOfObject:(id)object inSectionsArray:(NSArray *)sections {
    for (NSInteger section = 0; section < sections.count; section++) {
        NSArray *items = sections[section];
        
        if ([items containsObject:object]) {
            return [NSIndexPath indexPathForItem:[items indexOfObject:object] inSection:section];
        }
    }
    
    return nil;
}

@end
