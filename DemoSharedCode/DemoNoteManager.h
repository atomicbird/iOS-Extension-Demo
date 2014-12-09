//
//  DemoNoteManager.h
//  DemoNotes
//
//  Created by Tom Harrington on 11/25/14.
//  Copyright (c) 2014 Atomic Bird LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString *const kDemoNotesNotificationFile;
extern NSString *const kDemoNotesSaveByAppNotification;
extern NSString *const kDemoNotesSaveByExtensionNotification;

@interface DemoNoteManager : NSObject

+ (instancetype)sharedManager;

- (NSManagedObjectContext *)createManagedObjectContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType;

- (void)startObservingChangeNotifications;
- (void)stopObservingChangeNotifications;
- (BOOL)saveManagedObjectContextWithNotification:(NSManagedObjectContext *)context error:(NSError **)error;

@end
