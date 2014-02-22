# EPSReactiveTableViewController

`EPSReactiveTableViewController` is a subclass of `UITableViewController` that automatically populates a table view, and animates the insertion and deletion of rows by observing changes to an array of model objects. It uses [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa), and is designed to be used with the [MVVM](http://en.wikipedia.org/wiki/Model_View_ViewModel) pattern.

## Usage

Subclass `EPSReactiveTableViewController`, and write an `init` method which calls `initWithStyle:bindingToKeyPath:onObject:` on `super` to set up the binding. The value at the key path must always be an `NSArray` containing objects that implement `-isEqual:` and `-hash`. No object should appear in the array more than once.

```objective-c
- (id)init {
    EPSExampleViewModel *viewModel = [EPSExampleViewModel new];
    self = [super initWithStyle:UITableViewStylePlain bindingToKeyPath:@"sortedObjects" onObject:viewModel];
    ...
    return self;
}
```

Override `tableView:cellForObject:atIndexPath:`.

```objective-c
- (UITableViewCell *)tableView:(UITableView *)tableView cellForObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    // Setup the cell using `object`
    return cell;
}
```

If you want to know when a cell is tapped on, subscribe to the `didSelectRowSignal` property.

```objective-c
[self.didSelectRowSignal subscribeNext:^(RACTuple *tuple) {
    RACTupleUnpack(NSString *text, NSIndexPath *indexPath, UITableView *tableView) = tuple;
    // Do something with `object`
}];
```

For a more complete example of how to use `EPSReactiveTableViewController`, see the [example project](https://github.com/ElectricPeelSoftware/EPSReactiveTableView/tree/master/Example).

To run the example project; clone the repo, and run `pod install` from the Project directory first.

## Requirements

EPSReactiveTableViewController requires [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa) 2.2 or higher.

## Installation

EPSReactiveTableViewController is available through [CocoaPods](http://cocoapods.org), to install it simply add the following line to your Podfile:

```ruby
pod "EPSReactiveTableViewController"
```

Alternatively, include `EPSReactiveTableViewController.h` and `EPSReactiveTableViewController.m` in your project, and install [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa) 2.2. by following their [installation instructions](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/master/README.md#importing-reactivecocoa).

## License

EPSReactiveTableViewController is available under the MIT license. See the LICENSE file for more info.

