//
//  EPSNote.m
//  ReactiveTableViewControllerExample
//
//  Created by Peter Stuart on 2/28/14.
//  Copyright (c) 2014 Electric Peel, LLC. All rights reserved.
//

#import "EPSNote.h"

@implementation EPSNote

-(NSString *)description {
    return [NSString stringWithFormat:@"%@: %@", [super description], self.text];
}

@end
