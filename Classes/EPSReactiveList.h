//
//  EPSReactiveList.h
//  ReactiveTableViewControllerExample
//
//  Created by Peter Stuart on 5/5/14.
//  Copyright (c) 2014 Electric Peel, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EPSReactiveList <NSObject>

/**
 If set to YES, insertions and deletions will be animated. Otherwise, the data will be reloaded when any changes are observed.
 
 @note Set to `YES` by default.
 */
@property (nonatomic) BOOL animateChanges;

/**
 Call this method to start observing an array property on the given object.
 @note The property at `keyPath` must be an `NSArray`.
 */
- (void)setBindingToKeyPath:(NSString *)keyPath onObject:(id)object;

/**
 @param object An object in the observed array.
 */
- (NSIndexPath *)indexPathForObject:(id)object;

/**
 @returns The object corresponding to `indexPath`.
 */
- (id)objectForIndexPath:(NSIndexPath *)indexPath;

/**
 Registers a cell class for use in rows that correspond to objects which are members of the given object class.
 @param cellClass A `UITableViewCell` subclass. `cellClass` must conform to <EPSReactiveListCell>.
 @param objectClass A class of model object that’s contained in the observed array.
 */
- (void)registerCellClass:(Class)cellClass forObjectsWithClass:(Class)objectClass;

@end

/**
 Cell classes registered for use in `registerCellClass:forObjectsWithClass:` must conform to this protocol.
 */
@protocol EPSReactiveListCell <NSObject>

/**
 This property will be set in `-tableView:cellForRowAtIndexPath:` with the cell’s corresponding object from the observed array.
 */
@property (nonatomic) id object;

@end
