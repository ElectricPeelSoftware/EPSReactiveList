//
//  EPSExampleCollectionViewController.m
//  ReactiveTableViewControllerExample
//
//  Created by Peter Stuart on 5/5/14.
//  Copyright (c) 2014 Electric Peel, LLC. All rights reserved.
//

#import "EPSExampleCollectionViewController.h"

#import "EPSExampleViewModel.h"
#import "EPSNoteCollectionViewCell.h"
#import "EPSNote.h"

@interface EPSExampleCollectionViewController ()

@property (nonatomic) EPSExampleViewModel *viewModel;

@end

@implementation EPSExampleCollectionViewController

- (id)init
{
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    flowLayout.itemSize = CGSizeMake(100, 100);
    
    self = [super initWithCollectionViewLayout:flowLayout];
    if (self == nil) return nil;
    
    _viewModel = [EPSExampleViewModel new];
    [self setBindingToKeyPath:@"sortedNotes" onObject:_viewModel];
    
    [self registerCellClass:[EPSNoteCollectionViewCell class] forObjectsWithClass:[EPSNote class]];

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
    EPSNote *note = [EPSNote new];
    note.text = [NSString stringWithFormat:@"%i", self.viewModel.sortedNotes.count];
    
//    [self.viewModel addNote:note];
}

#pragma mark - EPSReactiveCollectionViewControllerDelegate Methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemForObject:(EPSNote *)note atIndexPath:(NSIndexPath *)indexPath {
    if (self.editing == YES) {
        [self.viewModel removeNote:note];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Selected: %@", note.text] message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    }
}

@end
