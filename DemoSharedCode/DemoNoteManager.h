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

@interface DemoNoteManager : NSObject

+ (instancetype)sharedManager;

- (NSManagedObjectContext *)createManagedObjectContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType;

- (NSURL *)presenterNotificationFileURL;
- (void)saveManagedObjectContextWithPresenterNotification:(NSManagedObjectContext *)context;

@end
