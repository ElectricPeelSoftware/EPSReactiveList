//
//  EPSExampleViewController.m
//  ReactiveTableViewControllerExample
//
//  Created by Peter Stuart on 2/22/14.
//  Copyright (c) 2014 Electric Peel, LLC. All rights reserved.
//

#import "EPSExampleViewController.h"

#import "EPSExampleViewModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTKeyPathCoding.h>

@interface EPSExampleViewController ()

@property (nonatomic) EPSExampleViewModel *viewModel;

@end

@implementation EPSExampleViewController

- (id)init
{
    EPSExampleViewModel *viewModel = [EPSExampleViewModel new];
    self = [super initWithStyle:UITableViewStylePlain bindingToKeyPath:@keypath(viewModel, sortedObjects) onObject:viewModel];
    if (self == nil) return nil;
    
    _viewModel = viewModel;
    
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addObject:)];
    
    // Add segmented control for sorting list to nav item
    UISegmentedControl *sortSegmentedControl = [[UISegmentedControl alloc] initWithItems:@[ @"A–Z", @"Z–A" ]];
    sortSegmentedControl.selectedSegmentIndex = 0;
    self.navigationItem.titleView = sortSegmentedControl;
    
    RAC(self.viewModel, sortAscending) = [[sortSegmentedControl rac_newSelectedSegmentIndexChannelWithNilValue:@0]
        map:^NSNumber *(NSNumber *segment) {
            if (segment.integerValue == 0) return @YES;
            else return @NO;
        }];
    
    // Show an alert when a row is tapped
    [self.didSelectRowSignal subscribeNext:^(RACTuple *tuple) {
        RACTupleUnpack(NSString *text, NSIndexPath *indexPath, UITableView *tableView) = tuple;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:text message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:NSStringFromClass(UITableViewCell.class)];
}

- (void)addObject:(id)sender {
    [self.viewModel addObject:[NSString stringWithFormat:@"%i", self.viewModel.sortedObjects.count]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
    NSString *string = object;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(UITableViewCell.class) forIndexPath:indexPath];
    cell.textLabel.text = string;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [self objectForIndexPath:indexPath];
    [self.viewModel removeObject:object];
}

@end
