//
//  EPSReactiveTableViewController.m
//  EPSReactiveTableVIewExample
//
//  Created by Peter Stuart on 2/21/14.
//  Copyright (c) 2014 Peter Stuart. All rights reserved.
//

#import "EPSReactiveTableViewController.h"

#import "EPSChangeObserver.h"

#import <ReactiveCocoa/RACEXTScope.h>
#import <ReactiveCocoa/RACEXTKeyPathCoding.h>

@interface EPSReactiveTableViewController ()

@property (readwrite, nonatomic) RACSignal *didSelectRowSignal;
@property (readwrite, nonatomic) RACSignal *accessoryButtonTappedSignal;

@property (nonatomic) EPSChangeObserver *changeObserver;
@property (nonatomic) NSDictionary *identifiersForClasses;

@end

@implementation EPSReactiveTableViewController

@synthesize animateChanges = _animateChanges;

#pragma mark - Public Methods

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self == nil) return nil;
    
    _animateChanges = YES;
    _insertAnimation = UITableViewRowAnimationAutomatic;
    _deleteAnimation = UITableViewRowAnimationAutomatic;
    _changeObserver = [EPSChangeObserver new];
    _identifiersForClasses = @{};
    
    RACSignal *didSelectMethodSignal = [self rac_signalForSelector:@selector(tableView:didSelectRowAtIndexPath:)];
    RACSignal *objectsWhenSelected = [RACObserve(self.changeObserver, objects) sample:didSelectMethodSignal];
    
    self.didSelectRowSignal = [[didSelectMethodSignal
        zipWith:objectsWhenSelected]
        map:^RACTuple *(RACTuple *tuple) {
            RACTupleUnpack(RACTuple *arguments, NSArray *objects) = tuple;
            RACTupleUnpack(UITableView *tableView, NSIndexPath *indexPath) = arguments;
            id object = [EPSReactiveTableViewController objectForIndexPath:indexPath inArray:objects];
            return RACTuplePack(object, indexPath, tableView);
        }];
    
    RACSignal *accessoryTappedSignal = [self rac_signalForSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)];
    RACSignal *objectsWhenAccessoryTapped = [RACObserve(self.changeObserver, objects) sample:accessoryTappedSignal];

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

- (void)setBindingToKeyPath:(NSString *)keyPath onObject:(id)object {
[self.changeObserver setBindingToKeyPath:keyPath onObject:object];
}

- (void)setSectionBindingToKeyPath:(NSString *)keyPath onObject:(id)object {
    [self.changeObserver setSectionBindingToKeyPath:keyPath onObject:object];
}

- (void)registerCellClass:(Class)cellClass forObjectsWithClass:(Class)objectClass {
    NSString *identifier = [EPSReactiveTableViewController identifierFromCellClass:cellClass objectClass:objectClass];
    [self.tableView registerClass:cellClass forCellReuseIdentifier:identifier];
    
    NSMutableDictionary *dictionary = [self.identifiersForClasses mutableCopy];
    dictionary[NSStringFromClass(objectClass)] = identifier;
    self.identifiersForClasses = dictionary;
}

- (NSIndexPath *)indexPathForObject:(id)object {
    return [EPSChangeObserver indexPathOfObject:object inSectionsArray:self.changeObserver.objects];
}

- (id)objectForIndexPath:(NSIndexPath *)indexPath {
    return [EPSReactiveTableViewController objectForIndexPath:indexPath inArray:self.changeObserver.objects];
}

+ (id)objectForIndexPath:(NSIndexPath *)indexPath inArray:(NSArray *)array {
    return array[indexPath.section][indexPath.row];
}

#pragma mark - Private Methods

- (void)viewDidLoad {
    [super viewDidLoad];

    @weakify(self);
    
    [self.changeObserver.changeSignal
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
    return self.changeObserver.objects.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.changeObserver.objects[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [self objectForIndexPath:indexPath];
    NSString *identifier = [self identifierForObject:object];
    
    if (identifier == nil) {
        return [self tableView:tableView cellForObject:object atIndexPath:indexPath];
    }
    
    UITableViewCell <EPSReactiveListCell> *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    if ([[cell class] conformsToProtocol:@protocol(EPSReactiveListCell)] == NO) {
        NSLog(@"EPSReactiveTableViewController Error: %@ does not conform to the <EPSReactiveListCell> protocol.", NSStringFromClass([cell class]));
    }
    
    cell.object = object;
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self tableView:tableView didSelectRowForObject:[self objectForIndexPath:indexPath] atIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self tableView:tableView accessoryButtonTappedForObject:[self objectForIndexPath:indexPath] atIndexPath:indexPath];
}

#pragma mark - For Subclasses

- (UITableViewCell *)tableView:(UITableView *)tableView cellForObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"EPSReactiveTableViewController Error: -tableView:cellForObject:atIndexPath: must be overridden by a subclass.");
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowForObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
}

@end
