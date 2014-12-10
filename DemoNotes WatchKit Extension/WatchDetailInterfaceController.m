//
//  WatchDetailInterfaceController.m
//  DemoNotes
//
//  Created by Tom Harrington on 12/9/14.
//  Copyright (c) 2014 Atomic Bird LLC. All rights reserved.
//

#import "WatchDetailInterfaceController.h"

@implementation WatchDetailInterfaceController

- (instancetype)initWithContext:(id)context {
    self = [super initWithContext:context];
    if (self){
        [self.textLabel setText:[context valueForKey:@"text"]];
    }
    return self;
}

@end
