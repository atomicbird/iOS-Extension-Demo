//
//  TodayViewController.m
//  DemoToday
//
//  Created by Tom Harrington on 11/13/14.
//  Copyright (c) 2014 Atomic Bird LLC. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import <DemoSharedCode/DemoSharedCode.h>

NSString *const kDemoNoteFilename = @"notes.bin";

@interface TodayViewController () <NCWidgetProviding>

@property (readwrite, strong) NSArray *objects;
@property (readwrite, strong) NSManagedObjectContext *managedObjectContext;
@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.managedObjectContext = [[DemoNoteManager sharedManager] createManagedObjectContextWithConcurrencyType:NSMainQueueConcurrencyType];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"DemoNote"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSError *fetchError = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    self.objects = fetchedObjects;

    self.preferredContentSize = CGSizeMake(self.preferredContentSize.width, self.objects.count * 44.0 /* self.tableView.rowHeight*/);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"demoTodayCell" forIndexPath:indexPath];
    
    DemoNote *object = self.objects[indexPath.row];
    cell.textLabel.text = [object text];
    cell.textLabel.textColor = [UIColor whiteColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"demonote:%ld", (long)indexPath.row]];
    [self.extensionContext openURL:url completionHandler:nil];
}

@end
