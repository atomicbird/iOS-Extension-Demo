//
//  InterfaceController.h
//  DemoNotes WatchKit Extension
//
//  Created by Tom Harrington on 12/9/14.
//  Copyright (c) 2014 Atomic Bird LLC. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface InterfaceController : WKInterfaceController
@property (weak, nonatomic) IBOutlet WKInterfaceTable *table;

@end
