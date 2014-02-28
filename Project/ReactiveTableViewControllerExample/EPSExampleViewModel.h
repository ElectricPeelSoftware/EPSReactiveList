//
//  EPSExampleViewModel.h
//  ReactiveTableViewControllerExample
//
//  Created by Peter Stuart on 2/22/14.
//  Copyright (c) 2014 Electric Peel, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EPSNote;

@interface EPSExampleViewModel : NSObject

@property (nonatomic) NSArray *sortedNotes;

@property (nonatomic) BOOL sortAscending;

- (void)addNote:(EPSNote *)object;
- (void)removeNote:(EPSNote *)object;

@end
