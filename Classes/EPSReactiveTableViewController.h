//
//  EPSReactiveTableViewController.h
//  EPSReactiveTableVIewExample
//
//  Created by Peter Stuart on 2/21/14.
//  Copyright (c) 2014 Peter Stuart. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <ReactiveCocoa/ReactiveCocoa.h>
#import "EPSReactiveList.h"

@interface EPSReactiveTableViewController : UITableViewController <EPSReactiveList>

/**
 The animation used when inserting rows.
 
 @note Set to `UITableViewRowAnimationAutomatic` by default.
 */
@property (nonatomic) UITableViewRowAnimation insertAnimation;

/**
 The animation used when deleting rows.
 
 @note Set to `UITableViewRowAnimationAutomatic` by default.
 */
@property (nonatomic) UITableViewRowAnimation deleteAnimation;

/**
 Override this method instead of `-tableView:cellForRowAtIndexPath`.
 @note Overriding this method is only necessary if you haven’t registered a cell class to use.
 @see -registerCellClass:forObjectsWithClass:
 @param object An object from the observed array.
 @param indexPath The index path corresponding to `object`.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForObject:(id)object atIndexPath:(NSIndexPath *)indexPath;

/**
 Override this method instead of `-tableView:didSelectRowAtIndexPath:`.
 @param object An object from the observed array.
 @param indexPath The index path corresponding to `object`.
 */
- (void)tableView:(UITableView *)tableView didSelectRowForObject:(id)object atIndexPath:(NSIndexPath *)indexPath;

/**
 Override this method instead of `-tableView:accessoryButtonTappedForRowWithIndexPath:`.
 @param object An object from the observed array.
 @param indexPath The index path corresponding to `object`.
 */
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForObject:(id)object atIndexPath:(NSIndexPath *)indexPath;

#pragma mark - Signals

/**
 A signal which sends a `RACTuple` with the object corresponding to the selected row, the index path of the selected row, and the table view, whenever a row is selected.
 
 @code
 [self.didSelectRowSignal subscribeNext:^(RACTuple *tuple) {
 RACTupleUnpack(id object, NSIndexPath *indexPath, UITableView *tableView) = tuple;
 // Do something with `object`.
 }
 @endcode
 */
@property (readonly, nonatomic) RACSignal *didSelectRowSignal;

/**
 A signal which sends a `RACTuple` with the object corresponding to the row whose accessory was tapped, the index path of the row, and the table view, whenever an accessory is tapped.
 */
@property (readonly, nonatomic) RACSignal *accessoryButtonTappedSignal;

@end
