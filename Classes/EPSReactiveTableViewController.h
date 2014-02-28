//
//  EPSReactiveTableViewController.h
//  EPSReactiveTableVIewExample
//
//  Created by Peter Stuart on 2/21/14.
//  Copyright (c) 2014 Peter Stuart. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <ReactiveCocoa/ReactiveCocoa.h>

@protocol EPSReactiveTableViewCell;

@interface EPSReactiveTableViewController : UITableViewController

/**
 If set to YES, insertions and deletions will be animated. Otherwise, the table view will be reloaded when any changes are observed.
 
 @note Set to \c YES by default.
 */
@property (nonatomic) BOOL animateChanges;

/**
 The animation used when inserting rows.
 
 @note Set to \c UITableViewRowAnimationAutomatic by default.
 */
@property (nonatomic) UITableViewRowAnimation insertAnimation;

/**
 The animation used when deleting rows.
 
 @note Set to \c UITableViewRowAnimationAutomatic by default.
 */
@property (nonatomic) UITableViewRowAnimation deleteAnimation;

/**
 A signal which sends a \c RACTuple with the object corresponding to the selected row, the index path of the selected row, and the table view.
 
 @code
 [self.didSelectRowSignal subscribeNext:^(RACTuple *tuple) {
     RACTupleUnpack(id object, NSIndexPath *indexPath, UITableView *tableView) = tuple;
     // Do something with `object`.
 }
 @endcode
 */
@property (readonly, nonatomic) RACSignal *didSelectRowSignal;

/**
 @param object An object in the observed array.
 */
- (NSIndexPath *)indexPathForObject:(id)object;

/**
 @returns The object corresponding to \c indexPath.
 */
- (id)objectForIndexPath:(NSIndexPath *)indexPath;

- (void)registerCellClass:(Class)cellClass forObjectsWithClass:(Class)objectClass;

// Methods to Override

/**
 @param style The table view style to use.
 @param keyPath The key path to observe on \c object. The value at the key path must always be an \c NSArray containing objects that implement \c -isEqual: and \c -hash. No object should appear in the array more than once.
 @param object The object whose key path will be observed.
 */
- (id)initWithStyle:(UITableViewStyle)style bindingToKeyPath:(NSString *)keyPath onObject:(id)object;

/**
 Override this method instead of \c -tableView:cellForRowAtIndexPath.
 
 @param object An object from the observed array.
 @param indexPath The index path corresponding to \c object.
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForObject:(id)object atIndexPath:(NSIndexPath *)indexPath;

@end

@protocol EPSReactiveTableViewCell <NSObject>

@property (nonatomic) id object;

@end