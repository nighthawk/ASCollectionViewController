//
//  ASDetailViewController.h
//  Example
//
//  Created by Adrian Schoenig on 7/05/13.
//  Copyright (c) 2013 Adrian Schoenig. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASDetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
