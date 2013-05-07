//
//  ASMasterViewController.h
//  Example
//
//  Created by Adrian Schoenig on 7/05/13.
//  Copyright (c) 2013 Adrian Schoenig. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

#import "ASCollectionViewController.h"

@interface ASMasterViewController : ASCollectionViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
