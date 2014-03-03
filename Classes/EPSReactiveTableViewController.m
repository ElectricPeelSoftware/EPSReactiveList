//
//  EPSReactiveTableViewController.m
//  EPSReactiveTableVIewExample
//
//  Created by Peter Stuart on 2/21/14.
//  Copyright (c) 2014 Peter Stuart. All rights reserved.
//

#import "EPSReactiveTableViewController.h"

#import <ReactiveCocoa/RACEXTScope.h>
#import <ReactiveCocoa/RACEXTKeyPathCoding.h>

@interface EPSReactiveTableViewController ()

@property (readwrite, nonatomic) RACSignal *didSelectRowSignal;
@property (readwrite, nonatomic) RACSignal *accessoryButtonTappedSignal;

@property (nonatomic) NSArray *objects;
@property (nonatomic) NSDictionary *identifiersForClasses;

@end

@implementation EPSReactiveTableViewController

#pragma mark - Public Methods

- (id)initWithStyle:(UITableViewStyle)style bindingToKeyPath:(NSString *)keyPath onObject:(id)object {
    self = [super initWithStyle:style];
    if (self == nil) return nil;
    
    _animateChanges = YES;
    _insertAnimation = UITableViewRowAnimationAutomatic;
    _deleteAnimation = UITableViewRowAnimationAutomatic;
    _identifiersForClasses = @{};
    
    RAC(self, objects) = [[object
        rac_valuesForKeyPath:keyPath observer:self]
        deliverOn:[RACScheduler mainThreadScheduler]];
    
    RACSignal *didSelectMethodSignal = [self rac_signalForSelector:@selector(tableView:didSelectRowAtIndexPath:)];
    RACSignal *objectsWhenSelected = [RACObserve(self, objects) sample:didSelectMethodSignal];
    
    self.didSelectRowSignal = [[didSelectMethodSignal
        zipWith:objectsWhenSelected]
        map:^RACTuple *(RACTuple *tuple) {
            RACTupleUnpack(RACTuple *arguments, NSArray *objects) = tuple;
            RACTupleUnpack(UITableView *tableView, NSIndexPath *indexPath) = arguments;
            id object = [EPSReactiveTableViewController objectForIndexPath:indexPath inArray:objects];
            return RACTuplePack(object, indexPath, tableView);
        }];
    
    RACSignal *accessoryTappedSignal = [self rac_signalForSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)];
    RACSignal *objectsWhenAccessoryTapped = [RACObserve(self, objects) sample:accessoryTappedSignal];

    self.accessoryButtonTappedSignal = [[accessoryTappedSignal
        zipWith:objectsWhenAccessoryTapped]
        map:^RACTuple *(RACTuple *tuple) {
            RACTupleUnpack(RACTuple *arguments, NSArray *objects) = tuple;
            RACTupleUnpack(UITableView *tableView, NSIndexPath *indexPath) = arguments;
            id object = [EPSReactiveTableViewController objectForIndexPath:indexPath inArray:objects];
            return RACTuplePack(object, indexPath, tableView);
        }];
    
    return self;
}

- (void)registerCellClass:(Class)cellClass forObjectsWithClass:(Class)objectClass {
    NSString *identifier = [EPSReactiveTableViewController identifierFromCellClass:cellClass objectClass:objectClass];
    [self.tableView registerClass:cellClass forCellReuseIdentifier:identifier];
    
    NSMutableDictionary *dictionary = [self.identifiersForClasses mutableCopy];
    dictionary[NSStringFromClass(objectClass)] = identifier;
    self.identifiersForClasses = dictionary;
}

- (NSIndexPath *)indexPathForObject:(id)object {
    return [NSIndexPath indexPathForRow:[self.objects indexOfObject:object] inSection:0];
}

- (id)objectForIndexPath:(NSIndexPath *)indexPath {
    return [EPSReactiveTableViewController objectForIndexPath:indexPath inArray:self.objects];
}

+ (id)objectForIndexPath:(NSIndexPath *)indexPath inArray:(NSArray *)array {
    return array[indexPath.row];
}

#pragma mark - Private Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    @weakify(self);
    
    RACSignal *changeSignal = [[self rac_valuesAndChangesForKeyPath:@keypath(self.objects) options:NSKeyValueObservingOptionOld observer:nil]
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
    
    [[changeSignal
        // Take only the first value so that we can reload the table view
        take:1]
        subscribeNext:^(id x) {
            @strongify(self);
            
            [self.tableView reloadData];
        }];
    
    [[changeSignal
        // Skip the first value since those changes shouldn't be animated
        skip:1]
        subscribeNext:^(RACTuple *tuple) {
            RACTupleUnpack(NSArray *rowsToRemove, NSArray *rowsToInsert) = tuple;
            
            @strongify(self);
            
            BOOL onlyOrderChanged = (rowsToRemove.count == 0) &&
                                    (rowsToInsert.count == 0);
            
            if (self.animateChanges == YES && onlyOrderChanged == NO) {
                [self.tableView beginUpdates];
                [self.tableView deleteRowsAtIndexPaths:rowsToRemove withRowAnimation:self.deleteAnimation];
                [self.tableView insertRowsAtIndexPaths:rowsToInsert withRowAnimation:self.insertAnimation];
                [self.tableView endUpdates];
            }
            else {
                [self.tableView reloadData];
            }
        }];
}

+ (NSString *)identifierFromCellClass:(Class)cellClass objectClass:(Class)objectClass {
    return [NSString stringWithFormat:@"EPSReactiveTableViewController-%@-%@", NSStringFromClass(cellClass), NSStringFromClass(objectClass)];
}

- (NSString *)identifierForObject:(id)object {
    return self.identifiersForClasses[NSStringFromClass([object class])];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [self objectForIndexPath:indexPath];
    NSString *identifier = [self identifierForObject:object];
    
    if (identifier == nil) {
        return [self tableView:tableView cellForObject:object atIndexPath:indexPath];
    }
    
    UITableViewCell <EPSReactiveTableViewCell> *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    if ([[cell class] conformsToProtocol:@protocol(EPSReactiveTableViewCell)] == NO) {
        NSLog(@"EPSReactiveTableViewController Error: %@ does not conform to the <EPSReactiveTableViewCell> protocol.", NSStringFromClass([cell class]));
    }
    
    cell.object = object;
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self tableView:tableView didSelectRowForObject:[self objectForIndexPath:indexPath] atIndexPath:indexPath];
}

#pragma mark - For Subclasses

- (UITableViewCell *)tableView:(UITableView *)tableView cellForObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"EPSReactiveTableViewController Error: -tableView:cellForObject:atIndexPath: must be overridden by a subclass.");
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowForObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
}

@end
