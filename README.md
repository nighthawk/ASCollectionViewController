# `ASCollectionViewController`

[![Badge w/ Version](http://cocoapod-badges.herokuapp.com/v/ASCollectionViewController/badge.png)](http://cocoadocs.org/docsets/ASCollectionViewController)
[![Badge w/ Platform](http://cocoapod-badges.herokuapp.com/p/ASCollectionViewController/badge.png)](http://cocoadocs.org/docsets/ASCollectionViewController)

A `UICollectionViewController` subclass that makes working with `NSFetchedResultsController`, `UIMenuController` and `UIRefreshControl` easier.

In particular it:
* Takes care of batching together any changes to your model to update the `collectionView`. This includes call backs if you need additional logic to respond to deletions/insertions/updates/moves.
* Enables long-tap menus on cells using `UIMenuItem` objects.
* Makes it easy to add a `UIRefreshControl` control.

The fetched results controller logic is taken from [Ash Furrow's code](https://github.com/AshFurrow/UICollectionView-NSFetchedResultsController) who in turn took it from [this gist](https://gist.github.com/4440c1cba83318e276bb).

# Setup

* Clone the repository
** Add `ASCollectionViewController.h` and `ASCollectionViewController.m` to your project.
** Subclass `ASCollectionViewController` instead of `UICollectionViewController`

## Using the `NSFetchedResultsController` helper

* Set the `managedObjectContext` property.
* Then call one of the `configureFetcher...` methods.
* Implement the `numberOfSectionsInCollectionView:`, `collectionView:numberOfItemsInSection:` and `collectionView:cellForItemAtIndexPath:` methods as usual. Note that you have access to the `fetchedResultsController` property to look up section info and objects.
* Any changes to the CoreData model will automatically be reflected.
* Implement the `handleFetchResultsControllerError` method as the default implementation is to crash with an `abort()` call.
* Optionally, implement any of the `didInsert/Delete/Update/MoveObject` methods if you need to so something special.

## Using the `UIMenuController` helper

* Call `addLongTapMenuItems:` with the `UIMenuItem` objects that you'd like to enable.
* Implement your selectors of those `UIMenuItem` objects. To get the element use the selection of the collection view.
* Optionally overwrite the `shouldShowMenuItemForAction:forItemAtIndexPath:` method to customise which
  action/menu item should be enabled for which item in your collection view.

## Using the `UIRefreshControl` helper

* Call `addRefreshControlWithTarget:action:` to add a `UIRefreshControl` to your collection view.
* Optionally, call `removeRefreshControl` to remove it again.

# Example

See the included example project for a very basic implementation.
