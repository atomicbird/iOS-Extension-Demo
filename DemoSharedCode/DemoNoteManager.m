//
//  DemoNoteManager.m
//  DemoNotes
//
//  Created by Tom Harrington on 11/25/14.
//  Copyright (c) 2014 Atomic Bird LLC. All rights reserved.
//

#import "DemoNoteManager.h"

static NSString *const kDemoNoteFilename = @"notes.sqlite";
NSString *const kDemoNotesNotificationFile = @"notes-notification.txt";

@interface DemoNoteManager ()
@property (readwrite, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readwrite, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end

@implementation DemoNoteManager

+ (instancetype)sharedManager
{
    static DemoNoteManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[DemoNoteManager alloc] init];
    });
    return sharedManager;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel == nil) {
        NSURL *modelURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"DemoNotes" withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator == nil) {
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        
        NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.atomicbird.demonotes"];
        NSURL *persistentStoreURL = [groupURL URLByAppendingPathComponent:kDemoNoteFilename];
        
        NSError *pscError = nil;
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                       configuration:nil
                                                                 URL:persistentStoreURL
                                                             options:@{ NSInferMappingModelAutomaticallyOption: @YES, NSMigratePersistentStoresAutomaticallyOption: @YES}
                                                               error:&pscError]) {
            NSLog(@"Error creating persistent store at %@: %@", persistentStoreURL, [pscError localizedDescription]);
        }
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)createManagedObjectContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:concurrencyType];
    [context setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    return context;
}

- (NSURL *)presenterNotificationFileURL
{
    NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.atomicbird.demonotes"];
    NSURL *notificationFileURL = [groupURL URLByAppendingPathComponent:kDemoNotesNotificationFile];
    return notificationFileURL;
}

- (void)saveManagedObjectContextWithPresenterNotification:(NSManagedObjectContext *)context
{
    NSError *saveError = nil;
    if ([context save:&saveError]) {
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
        NSError *coordinatedWriteError = nil;
        [fileCoordinator coordinateWritingItemAtURL:[self presenterNotificationFileURL] options:0 error:&coordinatedWriteError byAccessor:^(NSURL *newURL) {
            NSString *dateString = [[NSDate date] description];
            NSError *writeError = nil;
            if (![dateString writeToURL:newURL atomically:YES encoding:NSUTF8StringEncoding error:&writeError]) {
                NSLog(@"Error in coordinated write: %@", [writeError localizedDescription]);
            }
        }];
    } else {
        NSLog(@"Core Data save error: %@", [saveError localizedDescription]);
    }
}

@end
