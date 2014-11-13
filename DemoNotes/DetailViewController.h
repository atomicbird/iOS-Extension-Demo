//
//  DetailViewController.h
//  DemoNotes
//
//  Created by Tom Harrington on 11/12/14.
//  Copyright (c) 2014 Atomic Bird LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DemoSharedCode/DemoSharedCode.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) DemoNote *detailItem;

@end

