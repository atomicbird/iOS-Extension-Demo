//
//  AppDelegate.h
//  DemoNotes
//
//  Created by Tom Harrington on 11/12/14.
//  Copyright (c) 2014 Atomic Bird LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *noteRequestedNotification;
extern NSString *noteRequestedIndex;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@end

