//
//  EPSChangeObserver.h
//  ReactiveTableViewControllerExample
//
//  Created by Peter Stuart on 5/5/14.
//  Copyright (c) 2014 Electric Peel, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ReactiveCocoa/ReactiveCocoa.h>

@interface EPSChangeObserver : NSObject

@property (readonly, nonatomic) NSArray *objects;
@property (readonly, nonatomic) RACSignal *changeSignal;

- (void)setBindingToKeyPath:(NSString *)keyPath onObject:(id)object;

@end
