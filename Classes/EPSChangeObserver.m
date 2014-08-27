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
    
    RAC(self, objects) = [[RACSignal
        zip:@[ [RACObserve(self, object) skip:1], [RACObserve(self, keyPath) skip:1] ]
        reduce:^RACSignal *(id object, NSString *keyPath){
            return [object rac_valuesForKeyPath:keyPath observer:self];
        }]
        switchToLatest];
    
    _changeSignal = [[self rac_valuesAndChangesForKeyPath:@"objects" options:NSKeyValueObservingOptionOld observer:nil]
        map:^RACTuple *(RACTuple *tuple) {
            RACTupleUnpack(NSArray *newObjects, NSDictionary *changeDictionary) = tuple;
            id oldObjects = changeDictionary[NSKeyValueChangeOldKey];
            
            NSArray *oldObjectsArray;
            if (oldObjects == [NSNull null]) oldObjectsArray = @[];
            else oldObjectsArray = oldObjects;
            
            NSArray *rowsToRemove;
            
            rowsToRemove = [[[oldObjectsArray.rac_sequence
                filter:^BOOL(id object) {
                    return [newObjects containsObject:object] == NO;
                }]
                map:^NSIndexPath *(id object) {
                    return [NSIndexPath indexPathForRow:[oldObjects indexOfObject:object] inSection:0];
                }]
                array];
            
            NSArray *rowsToInsert = [[[newObjects.rac_sequence
                filter:^BOOL(id object) {
                    return ([oldObjectsArray containsObject:object] == NO);
                }]
                map:^NSIndexPath *(id object) {
                    return [NSIndexPath indexPathForRow:[newObjects indexOfObject:object] inSection:0];
                }]
                array];
            
            return RACTuplePack(rowsToRemove, rowsToInsert);
        }];
    
    return self;
}

- (void)setBindingToKeyPath:(NSString *)keyPath onObject:(id)object {
    self.object = object;
    self.keyPath = keyPath;
}

@end
