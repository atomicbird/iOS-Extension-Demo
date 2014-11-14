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

- (NSURL *)demoNoteFileURL
{
    NSURL *groupURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.atomicbird.demonotes"];
    NSURL *fileURL = [groupURL URLByAppendingPathComponent:kDemoNoteFilename];
    return fileURL;
}

- (void)didSelectPost {
    // Load existing notes
    NSMutableArray *objects;
    
    NSData *savedData = [NSData dataWithContentsOfURL:[self demoNoteFileURL]];
    if (savedData != nil) {
        NSArray *savedObjects = [NSKeyedUnarchiver unarchiveObjectWithData:savedData];
        if (savedObjects != nil) {
            objects = [savedObjects mutableCopy];
        }
    }
    
    if (objects == nil) {
        objects = [NSMutableArray array];
    }

    // Create a new note with the current text
    DemoNote *newNote = [[DemoNote alloc] initWithText:self.textView.text];
    [objects insertObject:newNote atIndex:0];

    // Save notes back to the file
    NSData *saveData = [NSKeyedArchiver archivedDataWithRootObject:objects];
    [saveData writeToURL:[self demoNoteFileURL] atomically:YES];

    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return @[];
}

@end
