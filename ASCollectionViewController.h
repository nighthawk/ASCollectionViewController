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

/** The managed object context. Make sure to set this first.
 */
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

/** Configures the fetched results controller.
 
 NOTE: You only need to call on of the providerd `configureFetcher` methods.
 
 @param klass           The class representing the entity to fetch. Needs to be 
                        a subclass of `NSManagedObject`.
 @param predicate       Optional predicate to filter results.
 @param sortDescriptors Optional sort descriptors.
 */
- (void)configureFetcherWithClass:(Class)klass
												predicate:(NSPredicate *)predicate
									sortDescriptors:(NSArray *)sortDescriptors;

/** Configures the fetched results controller.
 
 NOTE: You only need to call on of the providerd `configureFetcher` methods.
 
 @param entityName      The name of the entity to fetch.
 @param predicate       Optional predicate to filter results.
 @param sortDescriptors Optional sort descriptors.
 */
- (void)configureFetcherWithEntityName:(NSString *)entityName
														 predicate:(NSPredicate *)predicate
											 sortDescriptors:(NSArray *)sortDescriptors;


#pragma mark - Long-tap menu helper

/** Adds a long-tap menu with the specified items to the cells of the collection 
 view.
 
 @param menuItems A list of `UIMenuItem` objects
 */
- (void)addLongTapMenuItems:(NSArray *)menuItems;


#pragma mark - Pull to refresh helper

/** Adds a refresh control to the collection view.
 
 @param target An object that is a recipient of action messages sent by the 
               receiver when the represented gesture occurs. `nil` is not a 
               valid value.
 @param sender A selector identifying a method of a target to be invoked by the 
               action message. `NULL` is not a valid value.
 @return The `UIRefreshControl` instance that got added. Use this to customise
         its appearance. No need to retain it.
 */
- (UIRefreshControl *)addRefreshControlWithTarget:(id)target action:(SEL)selector;


#pragma mark - Helpers for subclasses

/** Optional callback when an object got inserted. No need to call super.
 
 @param object    The object in controller’s fetched results that changed.
 @param indexPath The destination path for the object.
 */
- (void)didInsertObject:(id)object atIndexPath:(NSIndexPath *)indexPath;

/** Optional callback when an object got deleted. No need to call super.
 
 @param object    The object in controller’s fetched results that changed.
 @param indexPath The index path of the changed object.
 */
- (void)didDeleteObject:(id)object atIndexPath:(NSIndexPath *)indexPath;

/** Optional callback when an object got updated. No need to call super.
 
 @param object    The object in controller’s fetched results that changed.
 @param indexPath The index path of the changed object.
 */
- (void)didUpdateObject:(id)object atIndexPath:(NSIndexPath *)indexPath;

/** Optional callback when an object got moved. No need to call super.
 
 @param object      The object in controller’s fetched results that changed.
 @param indexPath   The old index path of the changed object.
 @param toIndexPath The new index path of the changed object.
 */
- (void)didMoveObject:(id)object
				fromIndexPath:(NSIndexPath *)indexPath
					toIndexPath:(NSIndexPath *)toIndexPath;

@end