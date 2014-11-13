//
//  DemoNote.h
//  DemoNotes
//
//  Created by Tom Harrington on 11/12/14.
//  Copyright (c) 2014 Atomic Bird LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DemoNote : NSObject <NSCoding, NSCopying>

- (id)initWithText:(NSString *)text;

@property (readwrite, strong, nonatomic) NSString *text;
@property (readonly, copy) NSDate *dateCreated;
@property (readonly, copy) NSDate *dateModified;
@property (readwrite) BOOL hasChanges;

@end
