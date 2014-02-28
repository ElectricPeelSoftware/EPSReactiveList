//
//  EPSNoteCell.h
//  ReactiveTableViewControllerExample
//
//  Created by Peter Stuart on 2/28/14.
//  Copyright (c) 2014 Electric Peel, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <EPSReactiveTableViewController/EPSReactiveTableViewController.h>

@class EPSNote;

@interface EPSNoteCell : UITableViewCell <EPSReactiveTableViewCell>

@property (nonatomic, strong) EPSNote *object;

@end
