//
//  DemoNoteManager.m
//  DemoNotes
//
//  Created by Tom Harrington on 11/25/14.
//  Copyright (c) 2014 Atomic Bird LLC. All rights reserved.
//

#import "DemoNoteManager.h"

static NSString *const kDemoNoteFilename = @"notes.sqlite";
NSString *const kDemoNotesSaveByAppNotification = @"kDemoNotesSaveByAppNotification";
NSString *const kDemoNotesSaveByExtensionNotification = @"kDemoNotesSaveByExtensionNotification";

@interface DemoNoteManager ()
@property (readwrite, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readwrite, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readwrite, assign) BOOL observingChangeNotifications;
@end

void sharedDataChangedCallback(CFNotificationCenterRef postingCenter,
                               void * observer,
                               CFStringRef name,
                               void const * object,
                               CFDictionaryRef userInfo)
{
    // Springboard from Darwin notification center to NSNotificationCenter.
    // Note that most of the received arguments are NULL with the Darwin notification center.
    [[NSNotificationCenter defaultCenter] postNotificationName:kDemoNotesSaveByAppNotification object:[DemoNoteManager sharedManager]];
}

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

- (void)startObservingChangeNotifications
{
    if (self.observingChangeNotifications == NO) {
        CFNotificationCenterRef const center = CFNotificationCenterGetDarwinNotifyCenter();
        // The last two arguments below (object and suspensionBehavior) are ignored by the Darwin notification center.
        CFNotificationCenterAddObserver(center, NULL, sharedDataChangedCallback, (CFStringRef)self.observingSaveNotificationName, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
        
        self.observingChangeNotifications = YES;
    }
}

- (void)stopObservingChangeNotifications
{
    if (self.observingChangeNotifications == YES) {
        CFNotificationCenterRef const center = CFNotificationCenterGetDarwinNotifyCenter();
        CFNotificationCenterRemoveObserver(center, NULL, (CFStringRef)self.observingSaveNotificationName, NULL);
        self.observingChangeNotifications = NO;
    }
}

- (BOOL)runningInAppExtension
{
    // Check where we're running so that we can observe the right notification. This prevents
    // notifying anyone of their own changes.
    BOOL inExtension;
    
    if ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"NSExtension"] == nil) {
        inExtension = NO;
    } else {
        inExtension = YES;
    }
    
    return inExtension;
}

- (NSString *)observingSaveNotificationName
{
    NSString *observingNotificationName;
    if ([self runningInAppExtension]) {
        observingNotificationName = kDemoNotesSaveByAppNotification;
    } else {
        observingNotificationName = kDemoNotesSaveByExtensionNotification;
    }
    return observingNotificationName;
}

- (NSString *)postingSaveNotificationName
{
    NSString *observingNotificationName;
    if ([self runningInAppExtension]) {
        observingNotificationName = kDemoNotesSaveByExtensionNotification;
    } else {
        observingNotificationName = kDemoNotesSaveByAppNotification;
    }
    return observingNotificationName;
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

- (BOOL)saveManagedObjectContextWithNotification:(NSManagedObjectContext *)context error:(NSError **)error
{
    NSError *saveError = nil;
    BOOL success = [context save:&saveError];
    if (success) {
        CFNotificationCenterRef const center = CFNotificationCenterGetDarwinNotifyCenter();
        // Note that all but the first two arguments below are ignored by the Darwin notification center.
        CFNotificationCenterPostNotification(center, (CFStringRef)self.postingSaveNotificationName, NULL, NULL, YES);
    } else {
        NSLog(@"Core Data save error: %@", [saveError localizedDescription]);
        if (error != nil) {
            *error = saveError;
        }
    }
    return success;
}

@end
