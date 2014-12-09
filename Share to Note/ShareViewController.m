//
//  ShareViewController.m
//  Share to Note
//
//  Created by Tom Harrington on 11/14/14.
//  Copyright (c) 2014 Atomic Bird LLC. All rights reserved.
//

#import "ShareViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <DemoSharedCode/DemoSharedCode.h>

NSString *const kDemoNoteFilename = @"notes.bin";

@interface ShareViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ShareViewController

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypePropertyList]) {
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypePropertyList options:nil completionHandler:^(NSDictionary *jsDict, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSDictionary *jsPreprocessingResults = jsDict[NSExtensionJavaScriptPreprocessingResultsKey];
                        NSString *selectedText = jsPreprocessingResults[@"selection"];
                        NSString *pageTitle = jsPreprocessingResults[@"title"];
                        if ([selectedText length] > 0) {
                            self.textView.text = selectedText;
                        } else if ([pageTitle length] > 0) {
                            self.textView.text = pageTitle;
                        }
                    });
                }];
                
                break;
            }
        }
        
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.textView becomeFirstResponder];
}

- (IBAction)createNote:(id)sender {
    NSManagedObjectContext *context = [[DemoNoteManager sharedManager] createManagedObjectContextWithConcurrencyType:NSMainQueueConcurrencyType];
    DemoNote *newNote = [NSEntityDescription insertNewObjectForEntityForName:@"DemoNote" inManagedObjectContext:context];
    [newNote setText:self.textView.text];
    
    [[DemoNoteManager sharedManager] saveManagedObjectContextWithNotification:context error:nil];
    
    [self.extensionContext completeRequestReturningItems:nil completionHandler:nil];
}

- (IBAction)cancel:(id)sender {
    [self.extensionContext cancelRequestWithError:nil];
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return @[];
}

@end
