//
//  ASCollectionViewController.h
//
//  Created by Adrian Schoenig on 07/05/13.
//  Copyright (c) 2013 Adrian Schoenig. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ASCollectionViewControllerFetchRequestBlock)(NSFetchRequest *request);

@interface ASCollectionViewController : UICollectionViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong, readonly, nullable) NSFetchedResultsController *fetchedResultsController;

#pragma mark - Necessities to set up fetched results controller

/** The managed object context. Make sure to set this first.
 */
@property (nonatomic, strong, nullable) NSManagedObjectContext *managedObjectContext;

/** Configures the fetched results controller.
 
 NOTE: You only need to call on of the provided `configureFetcher` methods.
 
 @param klass           The class representing the entity to fetch. Needs to be 
                        a subclass of `NSManagedObject`.
 @param predicate       Optional predicate to filter results.
 @param sortDescriptors Optional sort descriptors.
 @param cacheName			  Optional name for the cache.
 */
- (void)configureFetcherWithClass:(Class)klass
												predicate:(nullable NSPredicate *)predicate
									sortDescriptors:(nullable NSArray *)sortDescriptors
												cacheName:(nullable NSString *)cacheName;

/** Configures the fetched results controller.
 
 NOTE: You only need to call on of the provided `configureFetcher` methods.
 
 @param entityName      The name of the entity to fetch.
 @param predicate       Optional predicate to filter results.
 @param sortDescriptors Optional sort descriptors.
 @param cacheName			  Optional name for the cache.
 */
- (void)configureFetcherWithEntityName:(NSString *)entityName
														 predicate:(nullable NSPredicate *)predicate
											 sortDescriptors:(nullable NSArray *)sortDescriptors
														 cacheName:(nullable NSString *)cacheName;

/** Configures the fetched results controller.
 
 NOTE: You only need to call on of the provided `configureFetcher` methods.
 
 @param klass           The class representing the entity to fetch. Needs to be
 a subclass of `NSManagedObject`.
 @param cacheName			  Optional name for the cache.
 @param requestBlock    Optional block which gets the fetch request passed in
 */
- (void)configureFetcherWithClass:(Class)klass
												cacheName:(nullable NSString *)cacheName
								 usedFetchRequest:(nullable ASCollectionViewControllerFetchRequestBlock)requestBlock;

/** Configures the fetched results controller.
 
 NOTE: You only need to call on of the provided `configureFetcher` methods.
 
 @param entityName      The name of the entity to fetch.
 @param cacheName			  Optional name for the cache.
 @param requestBlock    Optional block which gets the fetch request passed in
 */
- (void)configureFetcherWithEntityName:(NSString *)entityName
														 cacheName:(nullable NSString *)cacheName
											usedFetchRequest:(nullable ASCollectionViewControllerFetchRequestBlock)requestBlock;


#pragma mark - Long-tap menu helper

/** Adds a long-tap menu with the specified items to the cells of the collection 
 view.
 
 @param menuItems A list of `UIMenuItem` objects
 */
- (void)addLongTapMenuItems:(NSArray *)menuItems;

/** Optional method to overwrite to determine which menu-item action should be
  enabled for which index path.
 
 @param action    The action of a menu item
 @param indexpath The index path of the item in the collection view
 @return `true` if the menu item should be enabled/displayed for the specified
         index path.
 */
- (BOOL)shouldShowMenuItemForAction:(SEL)action
								 forItemAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark - Pull to refresh helper

/** The refresh control of the collection view if there's one.
 @ return The `UIRefreshControl` instance previously added or `nil`.
 */
- (nullable UIRefreshControl *)refreshControl;

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

/** Removed the refresh control again from the collection view.
 */
- (void)removeRefreshControl;

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

/** This method should be overridden by subclasses to handle errors that may occur when performing the inital fetch in the fetched results controller 
 
 @param error     The error that occurred when performing the initial fetch on the fetchedResultsController
 */
- (void) handleFetchResultsControllerError:(NSError*)error;

@end

NS_ASSUME_NONNULL_END
