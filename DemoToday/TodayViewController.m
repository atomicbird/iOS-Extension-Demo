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

@interface TodayViewController () <NCWidgetProviding, NSFilePresenter>

@property (readwrite, strong) NSMutableArray *objects;

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:self];
    NSError *fileCoordinatorError = nil;
    __weak typeof(self) weakSelf = self;
    [fileCoordinator coordinateReadingItemAtURL:[self presentedItemURL] options:0 error:&fileCoordinatorError byAccessor:^(NSURL *newURL) {
        NSData *savedData = [NSData dataWithContentsOfURL:newURL];
        if (savedData != nil) {
            NSArray *savedObjects = [NSKeyedUnarchiver unarchiveObjectWithData:savedData];
            if (savedObjects != nil) {
                weakSelf.objects = [savedObjects mutableCopy];
            }
        }
        
        if (weakSelf.objects == nil) {
            weakSelf.objects = [NSMutableArray array];
        }
    }];
    if (fileCoordinatorError != nil) {
        NSLog(@"Error loading notes: %@", [fileCoordinatorError localizedDescription]);
    }

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

#pragma mark - NSFilePresenter
- (NSURL *)presentedItemURL
{
    NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.atomicbird.demonotes"];
    NSURL *fileURL = [groupURL URLByAppendingPathComponent:kDemoNoteFilename];
    return fileURL;
}

- (NSOperationQueue *)presentedItemOperationQueue
{
    return [NSOperationQueue mainQueue];
}

- (void)presentedItemDidChange
{
    // This could be used to update the today view to show new or changed notes.
    // In this app it's not needed because new notes can't be created while the today extension is visible--
    // meaning that there's never a situation where this method would be useful.
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
