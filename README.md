# EPSReactiveList

EPSReactiveList provides subclasses of `UITableViewController` and `UICollectionViewController` that automatically populate a table/collection view, and animates the insertion and deletion of rows/items by observing changes to an array of model objects. It uses [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa), and is designed to be used with the [MVVM](http://en.wikipedia.org/wiki/Model_View_ViewModel) pattern.

EPSReactiveList replaces [EPSReactiveTableViewController](https://github.com/ElectricPeelSoftware/EPSReactiveTableViewController) and [EPSReactiveCollectionViewController](https://github.com/ElectricPeelSoftware/EPSReactiveCollectionViewController).

## Usage

Subclass either `EPSReactiveTableViewController` or `EPSReactiveCollectionViewController`, and write an `init` method which calls `setBindingToKeyPath:onObject:` to set up the binding. The value at the key path must always be an `NSArray` containing objects that implement `-isEqual:` and `-hash`. No object should appear in the array more than once. In the `init` method, register a cell class for use with the class of object that will be contained in the observed array. (The cell class must conform to `<EPSReactiveListCell>`.)

```objective-c
- (id)init {
  self = [super initWithStyle:UITableViewStylePlain];
  if (self == nil) return nil;

  _viewModel = [EPSExampleViewModel new];
  [self setBindingToKeyPath:@"sortedNotes" onObject:_viewModel];
  [self registerCellClass:[EPSNoteCell class] forObjectsWithClass:[EPSNote class]];
  ...
  return self;
}
```

To respond to taps on cells, override either `-tableView:didSelectRowForObject:atIndexPath:` or `-collectionView:didSelectItemForObject:atIndexPath:`, depending on whether you have subclassed `EPSReactiveTableViewController` or `EPSReactiveCollectionViewController`.

```objective-c
- (void)tableView:(UITableView *)tableView didSelectRowForObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
  // Do something with `object`
}
```

You don’t need to write any datasource methods.

For more complete examples of how to use `EPSReactiveTableViewController` and `EPSReactiveCollectionViewController`, see the [example project](https://github.com/ElectricPeelSoftware/EPSReactiveList/tree/master/Project).

## Example Project

To run the example project; clone the repo, and run `pod install` from the Project directory first.

## Requirements

EPSReactiveTableViewController requires [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa) 2.3 or higher.

## Installation

EPSReactiveList is available through [CocoaPods](http://cocoapods.org)—to install it simply add the following line to your Podfile:

```ruby
pod "EPSReactiveList"
```

Alternatively, include the files in the [Classes](https://github.com/ElectricPeelSoftware/EPSReactiveList/tree/master/Classes) directory in your project, and install [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa) 2.3 by following their [installation instructions](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/master/README.md#importing-reactivecocoa).

## License

EPSReactiveList is available under the MIT license. See the [LICENSE](https://github.com/ElectricPeelSoftware/EPSReactiveList/blob/master/LICENSE) file for more info.
