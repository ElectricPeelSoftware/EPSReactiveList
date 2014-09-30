//
//  EPSReactiveCollectionViewController.m
//  EPSReactiveCollectionViewController
//
//  Created by Peter Stuart on 3/3/14.
//  Copyright (c) 2014 Electric Peel, LLC. All rights reserved.
//

#import "EPSReactiveCollectionViewController.h"

#import "EPSChangeObserver.h"

#import <ReactiveCocoa/RACEXTScope.h>

@interface EPSReactiveCollectionViewController ()

@property (readwrite, nonatomic) RACSignal *didSelectItemSignal;

@property (nonatomic) EPSChangeObserver *changeObserver;
@property (nonatomic) NSDictionary *identifiersForClasses;

@end

@implementation EPSReactiveCollectionViewController

@synthesize animateChanges = _animateChanges;

#pragma mark - Public Methods

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithCollectionViewLayout:layout];
    if (self == nil) return nil;
    
    [self setup];

    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setup];
}

- (void)setup {
    _animateChanges = YES;
    _changeObserver = [EPSChangeObserver new];
    _identifiersForClasses = @{};
    
    RACSignal *didSelectMethodSignal = [self rac_signalForSelector:@selector(collectionView:didSelectItemAtIndexPath:)];
    RACSignal *objectsWhenSelected = [RACObserve(self.changeObserver, objects) sample:didSelectMethodSignal];
    
    self.didSelectItemSignal = [[didSelectMethodSignal
        zipWith:objectsWhenSelected]
        map:^RACTuple *(RACTuple *tuple) {
            RACTupleUnpack(RACTuple *arguments, NSArray *objects) = tuple;
            RACTupleUnpack(UICollectionView *collectionView, NSIndexPath *indexPath) = arguments;
            id object = [EPSReactiveCollectionViewController objectForIndexPath:indexPath inArray:objects];
            return RACTuplePack(object, indexPath, collectionView);
        }];
}

- (void)setBindingToKeyPath:(NSString *)keyPath onObject:(id)object {
    [self.changeObserver setSectionBindingToKeyPath:keyPath onObject:object];
}

- (void)registerCellClass:(Class)cellClass forObjectsWithClass:(Class)objectClass {
    NSString *identifier = [EPSReactiveCollectionViewController identifierFromCellClass:cellClass objectClass:objectClass];
    [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
    
    NSMutableDictionary *dictionary = [self.identifiersForClasses mutableCopy];
    dictionary[NSStringFromClass(objectClass)] = identifier;
    self.identifiersForClasses = dictionary;
}

- (NSIndexPath *)indexPathForObject:(id)object {
    return [NSIndexPath indexPathForRow:[self.changeObserver.objects indexOfObject:object] inSection:0];
}

- (id)objectForIndexPath:(NSIndexPath *)indexPath {
    return [EPSReactiveCollectionViewController objectForIndexPath:indexPath inArray:self.changeObserver.objects];
}

+ (id)objectForIndexPath:(NSIndexPath *)indexPath inArray:(NSArray *)array {
    return array[indexPath.row];
}

#pragma mark - Private Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    @weakify(self);
    
    [self.changeObserver.changeSignal
        subscribeNext:^(RACTuple *tuple) {
            RACTupleUnpack(NSArray *rowsToRemove, NSArray *rowsToInsert) = tuple;

            @strongify(self);

            BOOL onlyOrderChanged = (rowsToRemove.count == 0) && (rowsToInsert.count == 0);

            if (self.animateChanges == YES && onlyOrderChanged == NO) {
                [self.collectionView performBatchUpdates:^{
                    [self.collectionView deleteItemsAtIndexPaths:rowsToRemove];
                    [self.collectionView insertItemsAtIndexPaths:rowsToInsert];
                } completion:NULL];
            }
            else {
                [self.collectionView reloadData];
            }
        }];
}

+ (NSString *)identifierFromCellClass:(Class)cellClass objectClass:(Class)objectClass {
    return [NSString stringWithFormat:@"EPSReactiveCollectionViewController-%@-%@", NSStringFromClass(cellClass), NSStringFromClass(objectClass)];
}

- (NSString *)identifierForObject:(id)object {
    return self.identifiersForClasses[NSStringFromClass([object class])];
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.changeObserver.objects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id object = [self objectForIndexPath:indexPath];
    NSString *identifier = [self identifierForObject:object];
    
    if (identifier == nil) {
        return [self collectionView:collectionView cellForObject:object atIndexPath:indexPath];
    }
    
    UICollectionViewCell <EPSReactiveListCell> *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    if ([[cell class] conformsToProtocol:@protocol(EPSReactiveListCell)] == NO) {
        NSLog(@"EPSReactiveCollectionViewController Error: %@ does not conform to the <EPSReactiveListCell> protocol.", NSStringFromClass([cell class]));
    }
    
    cell.object = object;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self collectionView:collectionView didSelectItemForObject:[self objectForIndexPath:indexPath] atIndexPath:indexPath];
}

#pragma mark - For Subclasses

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"EPSReactiveCollectionViewController Error: -collectionView:cellForObject:atIndexPath: must be overridden by a subclass.");
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemForObject:(id)object atIndexPath:(NSIndexPath *)indexPath {    
}

@end
