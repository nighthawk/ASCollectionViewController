//
//  ASCollectionViewController.m
//
//  Created by Adrian Schoenig on 07/05/13.
//  Copyright (c) 2013 Adrian Schoenig. All rights reserved.
//

#import "ASCollectionViewController.h"

@interface ASCollectionViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSFetchRequest *fetchRequest;
@property (nonatomic, copy) NSString *cacheName;

@property (nonatomic, assign) BOOL shouldReloadCollectionView;
@property (nonatomic, strong) NSBlockOperation *blockOperation;

@property (nonatomic, strong) NSArray *menuItems;

@end

@implementation ASCollectionViewController

- (void)configureFetcherWithClass:(Class)klass
												predicate:(NSPredicate *)predicate
									sortDescriptors:(NSArray *)sortDescriptors
												cacheName:(NSString *)cacheName
{
	NSString *entityName = NSStringFromClass(klass);
	[self configureFetcherWithEntityName:entityName
														 predicate:predicate
											 sortDescriptors:sortDescriptors
														 cacheName:cacheName];
}

- (void)configureFetcherWithClass:(Class)klass
												cacheName:(NSString *)cacheName
								 usedFetchRequest:(ASCollectionViewControllerFetchRequestBlock)requestBlock
{
	NSString *entityName = NSStringFromClass(klass);
	[self configureFetcherWithEntityName:entityName
														 cacheName:cacheName
											usedFetchRequest:requestBlock];
}

- (void)configureFetcherWithEntityName:(NSString *)entityName
														 predicate:(NSPredicate *)predicate
											 sortDescriptors:(NSArray *)sortDescriptors
														 cacheName:(NSString *)cacheName
{
	[self configureFetcherWithEntityName:entityName
														 cacheName:cacheName
											usedFetchRequest:
	 ^(NSFetchRequest *request) {
		 request.sortDescriptors = sortDescriptors;
		 request.predicate = predicate;
	 }];
}

- (void)configureFetcherWithEntityName:(NSString *)entityName
														 cacheName:(NSString *)cacheName
											usedFetchRequest:(ASCollectionViewControllerFetchRequestBlock)requestBlock
{
	// get rid of the fetched results controller
	_fetchedResultsController = nil;
	
	// configure the fetch request
	_fetchRequest = [[NSFetchRequest alloc] init];
	_fetchRequest.entity = [NSEntityDescription entityForName:entityName
																		 inManagedObjectContext:self.managedObjectContext];;
	if (requestBlock) {
		requestBlock(_fetchRequest);
	}
	
	// set up the cache name
	if (cacheName != nil) {
		self.cacheName = cacheName;
	} else {
		self.cacheName = [NSString stringWithFormat:@"Cache%@", entityName];
	}
}


- (void)addLongTapMenuItems:(NSArray *)menuItems
{
	self.menuItems = menuItems;
	[UIMenuController sharedMenuController].menuItems = menuItems;
}

#pragma mark - UIRefreshControl related methods

- (UIRefreshControl *)refreshControl
{
	for (UIView *subview in self.collectionView.subviews) {
		if ([subview isKindOfClass:[UIRefreshControl class]]) {
			return (UIRefreshControl *) subview;
		}
	}
	return nil;
}

- (UIRefreshControl *)addRefreshControlWithTarget:(id)target action:(SEL)selector
{
	UIRefreshControl *refresher = [self refreshControl];
	if (! refresher) {
		UIRefreshControl *refresher = [[UIRefreshControl alloc] init];
		[self.collectionView addSubview:refresher];
	}
	
	[refresher addTarget:self action:selector
					 forControlEvents:UIControlEventValueChanged];
	self.collectionView.alwaysBounceVertical = YES;
	return refresher;
}

- (void)removeRefreshControl
{
	UIRefreshControl *refreshControl = [self refreshControl];
	[refreshControl removeTarget:nil action:NULL forControlEvents:UIControlEventValueChanged];
	self.collectionView.alwaysBounceVertical = NO;
}

#pragma mark - Defaults

- (void)didInsertObject:(id) object atIndexPath:(NSIndexPath *)indexPath
{
	return;
}

- (void)didDeleteObject:(id) object atIndexPath:(NSIndexPath *)indexPath
{
	return;
}

- (void)didUpdateObject:(id) object atIndexPath:(NSIndexPath *)indexPath
{
	return;
}

- (void)didMoveObject:(id) object
				fromIndexPath:(NSIndexPath *)indexPath
					toIndexPath:(NSIndexPath *)toIndexPath
{
	return;
}

#pragma mark - View controller

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	// re-assign menu items
	[UIMenuController sharedMenuController].menuItems = self.menuItems;
}

#pragma mark - Collection view delegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
{
	return self.menuItems.count > 0;
}

- (BOOL)collectionView:(UICollectionView *)collectionView
			canPerformAction:(SEL)action
		forItemAtIndexPath:(NSIndexPath *)indexPath
						withSender:(id)sender
{
	// select it to allow subclasses to determine what was tapped
	[collectionView selectItemAtIndexPath:indexPath
															 animated:NO
												 scrollPosition:UICollectionViewScrollPositionNone];
	
	return NO; // for defaults such as cut/copy/paste. the method which does the
	           // actual determination for which menu item should be shown for
	           // for item in the collection view is handled by
						 // `canPerformAction:withSender:` in combination with the custom
						 // `shouldShowMenuItemForAction:forItemAtIndexPath:` method.
}

- (void)collectionView:(UICollectionView *)collectionView
				 performAction:(SEL)action
		forItemAtIndexPath:(NSIndexPath *)indexPath
						withSender:(id)sender
{
	NSLog(@"WARNING: -collectionView:performAction:forItemAtIndexPath:withSender called but not overwritten by ASCollectionViewController subclass!");
}

#pragma mark - UIMenuController required methods

- (BOOL)shouldShowMenuItemForAction:(SEL)action
								 forItemAtIndexPath:(NSIndexPath *)indexPath;
{
	// By default the selector should match your UIMenuItem selector
	for (UIMenuItem *menuItem in self.menuItems) {
		if (menuItem.action == action)
			return YES;
	}
	
	return NO;
}

- (BOOL)canBecomeFirstResponder
{
	// NOTE: This menu item will not show if this is not YES!
	return self.menuItems.count > 0;
}

- (BOOL)canPerformAction:(SEL)action
							withSender:(id)sender
{
	NSIndexPath *indexPath = [self.collectionView indexPathsForSelectedItems].lastObject;
	return [self shouldShowMenuItemForAction:action forItemAtIndexPath:indexPath];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
	if (_fetchedResultsController != nil) {
		return _fetchedResultsController;
	}
	
	if (nil == self.fetchRequest) {
		@throw [NSException exceptionWithName:@"ASNotYetIntializedException"
																	 reason:@"Call any of the configureFetcher methods first"
																 userInfo:nil];
	}
	
	
	// Edit the section name key path and cache name if appropriate.
	// nil for section name key path means "no sections".
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:self.fetchRequest
																																															managedObjectContext:self.managedObjectContext
																																																sectionNameKeyPath:nil
																																																				 cacheName:self.cacheName];
	aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;
	
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
      [self handleFetchResultsControllerError:error];
	}
	
	return _fetchedResultsController;
}

- (void) handleFetchResultsControllerError:(NSError*)error
{
   // Override this implementation to handle the error appropriately.
   // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
   NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
   abort();
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
  self.shouldReloadCollectionView = NO;
  self.blockOperation = [NSBlockOperation new];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
  __weak UICollectionView *collectionView = self.collectionView;
  switch (type) {
    case NSFetchedResultsChangeInsert: {
      [self.blockOperation addExecutionBlock:^{
        [collectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
      }];
      break;
    }
      
    case NSFetchedResultsChangeDelete: {
      [self.blockOperation addExecutionBlock:^{
        [collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
      }];
      break;
    }
      
    case NSFetchedResultsChangeUpdate: {
      [self.blockOperation addExecutionBlock:^{
        [collectionView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
      }];
      break;
    }
      
    default:
      break;
  }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
  __weak UICollectionView *collectionView = self.collectionView;
  switch (type) {
    case NSFetchedResultsChangeInsert: {
			[self didInsertObject:anObject atIndexPath:newIndexPath];
      if ([self.collectionView numberOfSections] > 0) {
        if ([self.collectionView numberOfItemsInSection:indexPath.section] == 0) {
          self.shouldReloadCollectionView = YES;
        } else {
          [self.blockOperation addExecutionBlock:^{
            [collectionView insertItemsAtIndexPaths:@[newIndexPath]];
          }];
        }
      } else {
        self.shouldReloadCollectionView = YES;
      }
      break;
    }
      
    case NSFetchedResultsChangeDelete: {
			[self didDeleteObject:anObject atIndexPath:indexPath];
      if ([self.collectionView numberOfItemsInSection:indexPath.section] == 1) {
        self.shouldReloadCollectionView = YES;
      } else {
        [self.blockOperation addExecutionBlock:^{
          [collectionView deleteItemsAtIndexPaths:@[indexPath]];
        }];
      }
      break;
    }
      
    case NSFetchedResultsChangeUpdate: {
			[self didUpdateObject:anObject atIndexPath:indexPath];
      [self.blockOperation addExecutionBlock:^{
        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
      }];
      break;
    }
      
    case NSFetchedResultsChangeMove: {
			[self didMoveObject:anObject fromIndexPath:indexPath toIndexPath:newIndexPath];
      [self.blockOperation addExecutionBlock:^{
        [collectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
      }];
      break;
    }
      
    default:
      break;
  }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
  // Checks if we should reload the collection view to fix a bug @ http://openradar.appspot.com/12954582
  if (self.shouldReloadCollectionView) {
    [self.collectionView reloadData];
  } else {
    [self.collectionView performBatchUpdates:^{
      [self.blockOperation start];
    } completion:nil];
  }
}



@end
