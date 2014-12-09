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

@interface MasterViewController () <NSFetchedResultsControllerDelegate>

@property (readwrite, strong) NSIndexPath *editingNoteIndexPath;
@property (readwrite, strong) NSManagedObjectContext *managedObjectContext;
@property (readwrite, strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
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
    
    DemoNoteManager *sharedManager = [DemoNoteManager sharedManager];
    [sharedManager startObservingChangeNotifications];
    self.managedObjectContext = [sharedManager createManagedObjectContextWithConcurrencyType:NSMainQueueConcurrencyType];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(persistentStoreDidSave:)
                                                 name:kDemoNotesSaveByAppNotification
                                               object:[DemoNoteManager sharedManager]];

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
        self.editingNoteIndexPath = nil;
    }
}

- (void)openRequestedNote:(NSNotification *)notification
{
    NSInteger requestedItemIndex = [[notification userInfo][noteRequestedIndex] integerValue];
    if (requestedItemIndex < [[self.fetchedResultsController fetchedObjects] count]) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:requestedItemIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
        
        if ([[[self navigationController] visibleViewController] isKindOfClass:[DetailViewController class]]) {
            DetailViewController *detailViewController = (DetailViewController *)[[self navigationController] visibleViewController];
            DemoNote *requestedNote = [self.fetchedResultsController fetchedObjects][requestedItemIndex];
            detailViewController.detailItem = requestedNote;
        } else {
            [self performSegueWithIdentifier:@"showDetail" sender:self];
        }
    }
}

- (void)persistentStoreDidSave:(NSNotification *)unused
{
    NSError *fetchError = nil;
    if (![self.fetchedResultsController performFetch:&fetchError]) {
        NSLog(@"Fetch error: %@", fetchError);
    }
    [self.tableView reloadData];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController == nil) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"DemoNote"];
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dateCreated" ascending:NO];
        [fetchRequest setSortDescriptors:@[sortDescriptor]];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
        _fetchedResultsController.delegate = self;
        
        NSError *fetchError = nil;
        if (![_fetchedResultsController performFetch:&fetchError]) {
            NSLog(@"Error performing fetch: %@", fetchError);
        }
    }
    return _fetchedResultsController;
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
    NSString *newNoteTitle = [NSString stringWithFormat:@"Note %lu", (unsigned long)[[self.fetchedResultsController fetchedObjects] count]];
    DemoNote *newNote = [NSEntityDescription insertNewObjectForEntityForName:@"DemoNote" inManagedObjectContext:self.managedObjectContext];
    [newNote setText:newNoteTitle];
    [self saveNotes];
}

- (void)saveNotes
{
    NSError *saveError = nil;
    if (![[DemoNoteManager sharedManager] saveManagedObjectContextWithNotification:self.managedObjectContext error:&saveError]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Save error" message:[saveError localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"FRC will change content");
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
        {
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeDelete:
        {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeUpdate:
        {
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case NSFetchedResultsChangeMove:
        {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
            
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSLog(@"FRC content changed");
    [self.tableView endUpdates];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        DemoNote *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
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
    return [[self.fetchedResultsController fetchedObjects] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    DemoNote *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [object text];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        DemoNote *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.managedObjectContext deleteObject:object];
        [self saveNotes];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

@end
