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
#import "EPSNote.h"
#import "EPSNoteCell.h"

@interface EPSExampleViewController ()

@property (nonatomic) EPSExampleViewModel *viewModel;

@end

@implementation EPSExampleViewController

- (id)init
{
    EPSExampleViewModel *viewModel = [EPSExampleViewModel new];
    self = [super initWithStyle:UITableViewStylePlain bindingToKeyPath:@keypath(viewModel, sortedNotes) onObject:viewModel];
    if (self == nil) return nil;
    
    _viewModel = viewModel;
    
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
    
    // Show an alert when a row is tapped
    [self.didSelectRowSignal subscribeNext:^(RACTuple *tuple) {
        RACTupleUnpack(EPSNote *note, NSIndexPath *indexPath, UITableView *tableView) = tuple;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Selected: %@", note.text] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
    
    // Show an alert when an accessory is tapped
    [self.accessoryButtonTappedSignal subscribeNext:^(RACTuple *tuple) {
        RACTupleUnpack(EPSNote *note, NSIndexPath *indexPath, UITableView *tableView) = tuple;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Accessory: %@", note.text] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }];
    
    return self;
}

- (void)addObject:(id)sender {
    EPSNote *note = [EPSNote new];
    note.text = [NSString stringWithFormat:@"%i", self.viewModel.sortedNotes.count];
    
    [self.viewModel addNote:note];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    EPSNote *note = [self objectForIndexPath:indexPath];
    [self.viewModel removeNote:note];
}

@end
