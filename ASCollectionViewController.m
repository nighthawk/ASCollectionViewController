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

@property (nonatomic, strong) NSMutableArray *objectChanges;
@property (nonatomic, strong) NSMutableArray *sectionChanges;
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

- (void)configureFetcherWithEntityName:(NSString *)entityName
														 predicate:(NSPredicate *)predicate
											 sortDescriptors:(NSArray *)sortDescriptors
														 cacheName:(NSString *)cacheName
{
	// get rid of the fetched results controller
	_fetchedResultsController = nil;
	
	// configure the fetch request
	_fetchRequest = [[NSFetchRequest alloc] init];
	_fetchRequest.entity = [NSEntityDescription entityForName:entityName
																		 inManagedObjectContext:self.managedObjectContext];;
	_fetchRequest.sortDescriptors = sortDescriptors;
	_fetchRequest.predicate = predicate;
	
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

- (UIRefreshControl *)addRefreshControlWithTarget:(id)target action:(SEL)selector
{
	UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
	[refreshControl addTarget:self action:selector
					 forControlEvents:UIControlEventValueChanged];
	[self.collectionView addSubview:refreshControl];
	self.collectionView.alwaysBounceVertical = YES;
	return refreshControl;
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

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// for batch-processing fetched results controller changes
	self.objectChanges  = [NSMutableArray array];
	self.sectionChanges = [NSMutableArray array];
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
	return NO; // for default cut/copy/paste
}

- (void)collectionView:(UICollectionView *)collectionView
				 performAction:(SEL)action
		forItemAtIndexPath:(NSIndexPath *)indexPath
						withSender:(id)sender
{
	NSLog(@"WARNING: -collectionView:performAction:forItemAtIndexPath:withSender called but not overwritten by ASCollectionViewController subclass!");
}

#pragma mark - UIMenuController required methods

- (BOOL)canBecomeFirstResponder
{
	// NOTE: This menu item will not show if this is not YES!
	return self.menuItems.count > 0;
}

- (BOOL)canPerformAction:(SEL)action
							withSender:(id)sender
{
	// The selector(s) should match your UIMenuItem selector
	for (UIMenuItem *menuItem in self.menuItems) {
		if (menuItem.action == action)
			return YES;
	}
	return NO;
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
		// Replace this implementation with code to handle the error appropriately.
		// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
	
	return _fetchedResultsController;
}

- (void)controller:(NSFetchedResultsController *)controller
	didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
		 forChangeType:(NSFetchedResultsChangeType)type
{
	
	NSMutableDictionary *change = [NSMutableDictionary new];
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			change[@(type)] = @(sectionIndex);
			break;
		case NSFetchedResultsChangeDelete:
			change[@(type)] = @(sectionIndex);
			break;
	}
	
	[_sectionChanges addObject:change];
}

- (void)controller:(NSFetchedResultsController *)controller
	 didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
		 forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
	
	NSMutableDictionary *change = [NSMutableDictionary new];
	switch(type)
	{
		case NSFetchedResultsChangeInsert:
			[self didInsertObject:anObject atIndexPath:newIndexPath];
			change[@(type)] = newIndexPath;
			break;
		case NSFetchedResultsChangeDelete:
			[self didDeleteObject:anObject atIndexPath:indexPath];
			change[@(type)] = indexPath;
			break;
		case NSFetchedResultsChangeUpdate:
			[self didUpdateObject:anObject atIndexPath:indexPath];
			change[@(type)] = indexPath;
			break;
		case NSFetchedResultsChangeMove:
			[self didMoveObject:anObject fromIndexPath:indexPath toIndexPath:newIndexPath];
			change[@(type)] = @[indexPath, newIndexPath];
			break;
	}
	[_objectChanges addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	if ([_sectionChanges count] > 0)
	{
		[self.collectionView performBatchUpdates:^{
			
			for (NSDictionary *change in _sectionChanges)
			{
				[change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
					
					NSFetchedResultsChangeType type = [key unsignedIntegerValue];
					switch (type)
					{
						case NSFetchedResultsChangeInsert:
							[self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
							break;
						case NSFetchedResultsChangeDelete:
							[self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
							break;
						case NSFetchedResultsChangeUpdate:
							[self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
							break;
					}
				}];
			}
		} completion:nil];
	}
	
	if ([_objectChanges count] > 0 && [_sectionChanges count] == 0)
	{
		if ([self shouldReloadCollectionViewToPreventKnownIssue]) {
			// This is to prevent a bug in UICollectionView from occurring.
			// The bug presents itself when inserting the first object or deleting the last object in a collection view.
			// http://stackoverflow.com/questions/12611292/uicollectionview-assertion-failure
			// This code should be removed once the bug has been fixed, it is tracked in OpenRadar
			// http://openradar.appspot.com/12954582
			[self.collectionView reloadData];
			
		} else {
			
			[self.collectionView performBatchUpdates:^{
				
				for (NSDictionary *change in _objectChanges)
				{
					[change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
						
						NSFetchedResultsChangeType type = [key unsignedIntegerValue];
						switch (type)
						{
							case NSFetchedResultsChangeInsert:
								[self.collectionView insertItemsAtIndexPaths:@[obj]];
								break;
							case NSFetchedResultsChangeDelete:
								[self.collectionView deleteItemsAtIndexPaths:@[obj]];
								break;
							case NSFetchedResultsChangeUpdate:
								[self.collectionView reloadItemsAtIndexPaths:@[obj]];
								break;
							case NSFetchedResultsChangeMove:
								[self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
								break;
						}
					}];
				}
			} completion:nil];
		}
	}
	
	[_sectionChanges removeAllObjects];
	[_objectChanges removeAllObjects];
}

#pragma mark - Private helpers

- (BOOL)shouldReloadCollectionViewToPreventKnownIssue
{
	__block BOOL shouldReload = NO;
	for (NSDictionary *change in self.objectChanges) {
		[change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
			NSFetchedResultsChangeType type = [key unsignedIntegerValue];
			NSIndexPath *indexPath = obj;
			switch (type) {
				case NSFetchedResultsChangeInsert:
					if ([self.collectionView numberOfItemsInSection:indexPath.section] == 0) {
						shouldReload = YES;
					} else {
						shouldReload = NO;
					}
					break;
				case NSFetchedResultsChangeDelete:
					if ([self.collectionView numberOfItemsInSection:indexPath.section] == 1) {
						shouldReload = YES;
					} else {
						shouldReload = NO;
					}
					break;
				case NSFetchedResultsChangeUpdate:
					shouldReload = NO;
					break;
				case NSFetchedResultsChangeMove:
					shouldReload = NO;
					break;
			}
		}];
	}
	
	return shouldReload;
}



@end
