//
//  EPSNoteCollectionViewCell.h
//  ReactiveTableViewControllerExample
//
//  Created by Peter Stuart on 5/5/14.
//  Copyright (c) 2014 Electric Peel, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <EPSReactiveList/EPSReactiveCollectionViewController.h>

@class EPSNote;

@interface EPSNoteCollectionViewCell : UICollectionViewCell <EPSReactiveListCell>

@property (nonatomic, strong) EPSNote *object;

@end
