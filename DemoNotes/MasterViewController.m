//
//  MasterViewController.m
//  DemoNotes
//
//  Created by Tom Harrington on 11/12/14.
//  Copyright (c) 2014 Atomic Bird LLC. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import <DemoSharedCode/DemoSharedCode.h>
#import "AppDelegate.h"

NSString *const kDemoNoteFilename = @"notes.bin";

@interface MasterViewController () <NSFilePresenter>

@property (readwrite, strong) NSMutableArray *objects;
@property (readwrite, strong) NSPredicate *hasChangesPredicate;
@property (readwrite, strong) NSIndexPath *editingNoteIndexPath;
@property (readwrite, assign) BOOL forceSaveNeeded;
@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

    [NSFileCoordinator addFilePresenter:self];

    self.objects = [[self loadSavedNotes] mutableCopy];
    if (self.objects == nil) {
        self.objects = [NSMutableArray array];
    }
    
    _hasChangesPredicate = [NSPredicate predicateWithFormat:@"hasChanges = YES"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(openRequestedNote:)
                                                 name:noteRequestedNotification
                                               object:[[UIApplication sharedApplication] delegate]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.editingNoteIndexPath != nil) {
        [self saveNotes];
        [self.tableView reloadRowsAtIndexPaths:@[self.editingNoteIndexPath] withRowAnimation:NO];
        self.editingNoteIndexPath = nil;
    }
}

- (void)openRequestedNote:(NSNotification *)notification
{
    NSInteger requestedItemIndex = [[notification userInfo][noteRequestedIndex] integerValue];
    if (requestedItemIndex < self.objects.count) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:requestedItemIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
        
        if ([[[self navigationController] visibleViewController] isKindOfClass:[DetailViewController class]]) {
            DetailViewController *detailViewController = (DetailViewController *)[[self navigationController] visibleViewController];
            DemoNote *requestedNote = self.objects[requestedItemIndex];
            detailViewController.detailItem = requestedNote;
        } else {
            [self performSegueWithIdentifier:@"showDetail" sender:self];
        }
    }
}

- (NSURL *)demoNoteFileURL
{
    NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.atomicbird.demonotes"];
    NSURL *fileURL = [groupURL URLByAppendingPathComponent:kDemoNoteFilename];
    return fileURL;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {
    if (!self.objects) {
        self.objects = [[NSMutableArray alloc] init];
    }
    NSString *newNoteTitle = [NSString stringWithFormat:@"Note %lu", (unsigned long)[self.objects count]];
    DemoNote *newNote = [[DemoNote alloc] initWithText:newNoteTitle];
    [self.objects insertObject:newNote atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self saveNotes];
}

- (NSArray *)loadSavedNotes
{
    NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:self];
    NSError *fileCoordinatorError = nil;
    __block NSArray *savedNotes = nil;
    
    [fileCoordinator coordinateReadingItemAtURL:[self demoNoteFileURL] options:0 error:&fileCoordinatorError byAccessor:^(NSURL *newURL) {
        NSData *savedData = [NSData dataWithContentsOfURL:newURL];
        
        if (savedData != nil) {
            savedNotes = [NSKeyedUnarchiver unarchiveObjectWithData:savedData];
        }
    }];
    if (fileCoordinatorError != nil) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Load error" message:[fileCoordinatorError localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    return savedNotes;
}

- (void)saveNotes
{
    NSArray *changedObjects = [self.objects filteredArrayUsingPredicate:self.hasChangesPredicate];
    if ((changedObjects.count > 0) || self.forceSaveNeeded) {
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] initWithFilePresenter:self];
        __weak typeof(self) weakSelf = self;
        NSError *fileCoordinatorError = nil;
        
        [fileCoordinator coordinateWritingItemAtURL:[self demoNoteFileURL] options:NSFileCoordinatorWritingForReplacing error:&fileCoordinatorError byAccessor:^(NSURL *newURL) {
            NSData *saveData = [NSKeyedArchiver archivedDataWithRootObject:weakSelf.objects];
            [saveData writeToURL:newURL atomically:YES];
            [changedObjects makeObjectsPerformSelector:@selector(setHasChanges:) withObject:@NO];
            weakSelf.forceSaveNeeded = NO;
        }];
        if (fileCoordinatorError != nil) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Save error" message:[fileCoordinatorError localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

#pragma mark - NSFilePresenter
- (NSURL *)presentedItemURL
{
    return [self demoNoteFileURL];
}

- (NSOperationQueue *)presentedItemOperationQueue
{
    return [NSOperationQueue mainQueue];
}

- (void)presentedItemDidChange
{
    NSArray *savedNotes = [self loadSavedNotes];
    
    if (savedNotes.count > self.objects.count) {
        NSInteger newNoteCount = savedNotes.count - self.objects.count;
        NSArray *newNotes = [savedNotes subarrayWithRange:NSMakeRange(0, newNoteCount)];
        [self.objects insertObjects:newNotes atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newNoteCount)]];
        
        if (self.editingNoteIndexPath != nil) {
            // If a note is currently being edited, update the editing index path.
            // New notes always appear at the top of the list, so the editing index row increments by the number of new notes.
            self.editingNoteIndexPath = [NSIndexPath indexPathForRow:self.editingNoteIndexPath.row+newNoteCount inSection:0];
        }
        [self.tableView reloadData];
    }
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        DemoNote *object = self.objects[indexPath.row];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:object];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
        self.editingNoteIndexPath = [self.tableView indexPathForSelectedRow];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    DemoNote *object = self.objects[indexPath.row];
    cell.textLabel.text = [object text];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        self.forceSaveNeeded = YES;
        [self saveNotes];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

@end
