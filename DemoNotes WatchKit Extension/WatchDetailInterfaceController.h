//
//  WatchDetailInterfaceController.h
//  DemoNotes
//
//  Created by Tom Harrington on 12/9/14.
//  Copyright (c) 2014 Atomic Bird LLC. All rights reserved.
//

#import <WatchKit/WatchKit.h>

@interface WatchDetailInterfaceController : WKInterfaceController

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *textLabel;
@end
