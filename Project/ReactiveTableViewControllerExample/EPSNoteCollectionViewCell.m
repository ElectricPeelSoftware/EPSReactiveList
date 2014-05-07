//
//  EPSNoteCollectionViewCell.m
//  ReactiveTableViewControllerExample
//
//  Created by Peter Stuart on 5/5/14.
//  Copyright (c) 2014 Electric Peel, LLC. All rights reserved.
//

#import "EPSNoteCollectionViewCell.h"

#import "EPSNote.h"

@interface EPSNoteCollectionViewCell ()

@property (nonatomic) UILabel *label;

@end

@implementation EPSNoteCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self == nil) return nil;
    
    UILabel *label = [UILabel new];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.font = [UIFont systemFontOfSize:30];
    label.textAlignment = NSTextAlignmentCenter;
    self.label = label;
    
    [self.contentView addSubview:label];
    
    NSDictionary *views = NSDictionaryOfVariableBindings(label);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[label]|" options:0 metrics:nil views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[label]|" options:0 metrics:nil views:views]];
    
    self.backgroundColor = [UIColor whiteColor];
    
    return self;
}

- (void)setObject:(EPSNote *)object {
    _object = object;
    
    self.label.text = object.text;
}

@end
