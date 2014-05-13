//
//  EPSExampleViewController.m
//  ReactiveTableViewControllerExample
//
//  Created by Peter Stuart on 2/22/14.
//  Copyright (c) 2014 Electric Peel, LLC. All rights reserved.
//

#import "EPSExampleTableViewController.h"

#import "EPSExampleViewModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTKeyPathCoding.h>
#import "EPSNote.h"
#import "EPSNoteCell.h"

@interface EPSExampleTableViewController ()

@property (nonatomic) EPSExampleViewModel *viewModel;

@end

@implementation EPSExampleTableViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self == nil) return nil;
    
    _viewModel = [EPSExampleViewModel new];
    [self setSectionBindingToKeyPath:@"sortedNotes" onObject:_viewModel];

    [self registerCellClass:[EPSNoteCell class] forObjectsWithClass:[EPSNote class]];
    
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
    
    return self;
}

- (void)addObject:(id)sender {
    [self.viewModel addNote];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    EPSNote *note = [self objectForIndexPath:indexPath];
    [self.viewModel removeNote:note];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.viewModel titleForSection:section];
}

#pragma mark - EPSReactiveTableViewControllerDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowForObject:(EPSNote *)note atIndexPath:(NSIndexPath *)indexPath {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Selected: %@", note.text] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForObject:(EPSNote *)note atIndexPath:(NSIndexPath *)indexPath {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Accessory: %@", note.text] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
