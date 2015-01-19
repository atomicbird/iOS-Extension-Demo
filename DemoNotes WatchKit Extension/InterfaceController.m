//
//  InterfaceController.m
//  DemoNotes WatchKit Extension
//
//  Created by Tom Harrington on 12/9/14.
//  Copyright (c) 2014 Atomic Bird LLC. All rights reserved.
//

#import "InterfaceController.h"
#import "DemoNoteRowController.h"
#import <DemoSharedCode/DemoSharedCode.h>

@interface InterfaceController()

@property (readwrite, strong) NSManagedObjectContext *managedObjectContext;
@property (readwrite, strong) NSArray *notes;
@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Initialize variables here.
    // Configure interface objects here.
    NSLog(@"%@ initWithContext", self);
    self.managedObjectContext = [[DemoNoteManager sharedManager] createManagedObjectContextWithConcurrencyType:NSMainQueueConcurrencyType];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"DemoNote"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    [fetchRequest setResultType:NSDictionaryResultType];
    [fetchRequest setPropertiesToFetch:@[ @"text" ] ];
    
    NSError *fetchError = nil;
    self.notes = [self.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    if (self.notes == nil) {
        NSLog(@"Fetch error: %@", [fetchError localizedDescription]);
    }
    
    [self.table setNumberOfRows:self.notes.count withRowType:@"demoNoteRowType"];
    for (NSInteger index=0; index<self.notes.count; index++) {
        NSDictionary *noteInfo = self.notes[index];
        DemoNoteRowController *rowController = [self.table rowControllerAtIndex:index];
        
        [rowController.rowLabel setText:noteInfo[@"text"]];
    }
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex
{
    NSDictionary *tappedNote = self.notes[rowIndex];
    NSLog(@"Selected note %@ at index %ld", tappedNote[@"text"], (long)rowIndex);
    [self pushControllerWithName:@"watchDetail" context:tappedNote];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    NSLog(@"%@ will activate", self);
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    NSLog(@"%@ did deactivate", self);
}

@end



