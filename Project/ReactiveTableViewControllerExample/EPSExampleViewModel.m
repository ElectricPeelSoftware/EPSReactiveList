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

@interface EPSExampleViewModel ()

@property (nonatomic) NSSet *objects;

@end

@implementation EPSExampleViewModel

- (id)init {
    self = [super init];
    if (self == nil) return nil;
    
    _objects = [NSSet setWithArray:@[ @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z" ]];
    _sortAscending = YES;
    
    RAC(self, sortedObjects) = [RACSignal
        combineLatest:@[ RACObserve(self, objects), RACObserve(self, sortAscending) ]
        reduce:^NSArray *(NSSet *objects, NSNumber *sortAscending){
            return [objects sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:sortAscending.boolValue selector:@selector(localizedStandardCompare:)] ]];
        }];
    
    return self;
}

- (void)addObject:(NSString *)object {
    self.objects = [self.objects setByAddingObject:object];
}

- (void)removeObject:(NSString *)object {
    NSMutableSet *objects = self.objects.mutableCopy;
    [objects removeObject:object];
    self.objects = objects;
}

@end
