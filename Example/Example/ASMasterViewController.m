//
//  ASMasterViewController.m
//  Example
//
//  Created by Adrian Schoenig on 7/05/13.
//  Copyright (c) 2013 Adrian Schoenig. All rights reserved.
//

#import "ASMasterViewController.h"

#import "ASDetailViewController.h"

@implementation ASMasterViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// This is where we configure the fetcher
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
	[self configureFetcherWithEntityName:@"Event"
														 predicate:nil
											 sortDescriptors:@[sortDescriptor]
														 cacheName:nil];
	
	// add button
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
	self.navigationItem.rightBarButtonItem = addButton;
	
	// delete menu item
	UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:@"Delete" action:@selector(deleteObject:)];
	[self addLongTapMenuItems:@[deleteItem]];
}

- (void)deleteObject:(id)sender
{
	NSIndexPath *selection = [[self.collectionView indexPathsForSelectedItems] lastObject];
	id object = [self.fetchedResultsController objectAtIndexPath:selection];
	[self.managedObjectContext deleteObject:object];
}

- (void)insertNewObject:(id)sender
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
         // Replace this implementation with code to handle the error appropriately.
         // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([[segue identifier] isEqualToString:@"showDetail"]) {
		NSIndexPath *selection = [[self.collectionView indexPathsForSelectedItems] lastObject];
		NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:selection];
		[[segue destinationViewController] setDetailItem:object];
	}
}


#pragma mark - Collection view data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return self.fetchedResultsController.sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
		 numberOfItemsInSection:(NSInteger)section
{
	id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
	return [sectionInfo numberOfObjects];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
									cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	// get the cell
	UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];

	// configure it
	UILabel *label = (UILabel *)[cell viewWithTag:1];
	NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
	label.text = [[object valueForKey:@"timeStamp"] description];
	return cell;
}

@end
