//
//  DemoNote.m
//  DemoNotes
//
//  Created by Tom Harrington on 11/25/14.
//  Copyright (c) 2014 Atomic Bird LLC. All rights reserved.
//

#import "DemoNote.h"


@implementation DemoNote

@dynamic text;
@dynamic dateCreated;
@dynamic dateModified;

- (void)setText:(NSString *)text
{
    [self willChangeValueForKey:@"text"];
    [self setPrimitiveValue:text forKey:@"text"];
    [self didChangeValueForKey:@"text"];
    
    [self setDateModified:[NSDate date]];
}

- (void)awakeFromInsert
{
    NSDate *date = [NSDate date];
    [self setDateCreated:date];
    [self setDateModified:date];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ created %@: %@", [super description], self.dateCreated, self.text];
}

@end
