//
//  EPSReactiveCollectionViewController.h
//  EPSReactiveCollectionViewController
//
//  Created by Peter Stuart on 3/3/14.
//  Copyright (c) 2014 Electric Peel, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <ReactiveCocoa/ReactiveCocoa.h>
#import "EPSReactiveList.h"

@interface EPSReactiveCollectionViewController : UICollectionViewController <EPSReactiveList>

/**
 Override this method instead of `-collectionView:cellForItemAtIndexPath:`.
 @note Overriding this method is only necessary if you haven’t registered a cell class to use.
 @see -registerCellClass:forObjectsWithClass:
 @param object An object from the observed array.
 @param indexPath The index path corresponding to `object`.
 */
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForObject:(id)object atIndexPath:(NSIndexPath *)indexPath;

/**
 Override this method instead of `-collectionView:collectionView didSelectItemAtIndexPath:`.
 @note Overriding this method is only necessary if you haven’t registered a cell class to use.
 @see -registerCellClass:forObjectsWithClass:
 @param object An object from the observed array.
 @param indexPath The index path corresponding to `object`.
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemForObject:(id)object atIndexPath:(NSIndexPath *)indexPath;

#pragma mark - Signals

/**
 A signal which sends a `RACTuple` with the object corresponding to the selected item, the index path of the selected item, and the collection view, whenever an item is selected.
 
 @code
 [self.didSelectRowSignal subscribeNext:^(RACTuple *tuple) {
 RACTupleUnpack(id object, NSIndexPath *indexPath, UICollectionView *collectionView) = tuple;
 // Do something with `object`.
 }
 @endcode
 */
@property (readonly, nonatomic) RACSignal *didSelectItemSignal;

@end
