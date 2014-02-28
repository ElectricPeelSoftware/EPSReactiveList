//
//  EPSNoteCell.m
//  ReactiveTableViewControllerExample
//
//  Created by Peter Stuart on 2/28/14.
//  Copyright (c) 2014 Electric Peel, LLC. All rights reserved.
//

#import "EPSNoteCell.h"

#import "EPSNote.h"

@implementation EPSNoteCell

- (void)setObject:(EPSNote *)object {
    _object = object;
    
    self.textLabel.text = object.text;
}

@end
