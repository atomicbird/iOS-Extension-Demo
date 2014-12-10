//
//  DemoNoteRowController.h
//  DemoNotes
//
//  Created by Tom Harrington on 12/9/14.
//  Copyright (c) 2014 Atomic Bird LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>

@interface DemoNoteRowController : NSObject

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *rowLabel;
@end
