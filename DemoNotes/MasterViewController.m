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

NSString *const kDemoNoteFilename = @"notes.bin";

@interface MasterViewController ()

@property (readwrite, strong) NSMutableArray *objects;
@property (readwrite, strong) NSPredicate *hasChangesPredicate;
@property (readwrite, strong) NSIndexPath *editingNoteIndexPath;
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
    
    NSData *savedData = [NSData dataWithContentsOfURL:[self demoNoteFileURL]];
    if (savedData != nil) {
        NSArray *savedObjects = [NSKeyedUnarchiver unarchiveObjectWithData:savedData];
        if (savedObjects != nil) {
            self.objects = [savedObjects mutableCopy];
        }
    }
    
    if (self.objects == nil) {
        self.objects = [NSMutableArray array];
    }
    
    _hasChangesPredicate = [NSPredicate predicateWithFormat:@"hasChanges = YES"];
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

- (void)saveNotes
{
    NSArray *changedObjects = [self.objects filteredArrayUsingPredicate:self.hasChangesPredicate];
    if (changedObjects.count > 0) {
        NSData *saveData = [NSKeyedArchiver archivedDataWithRootObject:self.objects];
        [saveData writeToURL:[self demoNoteFileURL] atomically:YES];
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
        [self saveNotes];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

@end
