//
//  WatchDetailInterfaceController.m
//  DemoNotes
//
//  Created by Tom Harrington on 12/9/14.
//  Copyright (c) 2014 Atomic Bird LLC. All rights reserved.
//

#import "WatchDetailInterfaceController.h"

@implementation WatchDetailInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    if (self){
        [self.textLabel setText:[context valueForKey:@"text"]];
    }
}

@end
