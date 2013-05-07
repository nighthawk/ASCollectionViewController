//
//  ASCollectionViewController.h
//
//  Created by Adrian Schoenig on 07/05/13.
//  Copyright (c) 2013 Adrian Schoenig. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface ASCollectionViewController : UICollectionViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchedResultsController;

#pragma mark - Necessities to set up fetched results controller

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (void)configureFetcherWithClass:(Class)klass
												predicate:(NSPredicate *)predicate
									sortDescriptors:(NSArray *)sortDescriptors;

- (void)configureFetcherWithEntityName:(NSString *)entityName
														 predicate:(NSPredicate *)predicate
											 sortDescriptors:(NSArray *)sortDescriptors;


#pragma mark - Long-tap menu helper

- (void)addLongTapMenuItems:(NSArray *)menuItems;


#pragma mark - Pull to refresh helper

- (UIRefreshControl *)addRefreshControlWithTarget:(id)target action:(SEL)selector;


#pragma mark - Helpers for subclasses

- (void)didInsertObject:(id) object atIndexPath:(NSIndexPath *)indexPath;

- (void)didDeleteObject:(id) object atIndexPath:(NSIndexPath *)indexPath;

- (void)didUpdateObject:(id) object atIndexPath:(NSIndexPath *)indexPath;

- (void)didMoveObject:(id) object
				fromIndexPath:(NSIndexPath *)indexPath
					toIndexPath:(NSIndexPath *)toIndexPath;

@end