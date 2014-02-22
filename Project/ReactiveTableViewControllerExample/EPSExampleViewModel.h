//
//  EPSExampleViewModel.h
//  ReactiveTableViewControllerExample
//
//  Created by Peter Stuart on 2/22/14.
//  Copyright (c) 2014 Electric Peel, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EPSExampleViewModel : NSObject

@property (nonatomic) NSArray *sortedObjects;

@property (nonatomic) BOOL sortAscending;

- (void)addObject:(NSString *)object;
- (void)removeObject:(NSString *)object;

@end
