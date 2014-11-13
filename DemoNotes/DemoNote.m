//
//  DemoNote.m
//  DemoNotes
//
//  Created by Tom Harrington on 11/12/14.
//  Copyright (c) 2014 Atomic Bird LLC. All rights reserved.
//

#import "DemoNote.h"

NSString *const kDemoNoteTextey = @"text";
NSString *const kDemoNoteDateCreatedKey = @"dateCreated";
NSString *const kDemoNoteDateModifiedKey = @"dateModified";

@implementation DemoNote

- (instancetype)initWithText:(NSString *)text
{
    if ((self = [super init])) {
        _text = [text copy];
        _dateCreated = [NSDate date];
        _dateModified = [NSDate date];
        _hasChanges = YES;
    }
    return self;
}

- (void)setText:(NSString *)text
{
    if (![text isEqualToString:_text]) {
        _text = [text copy];
        _dateModified = [NSDate date];
        _hasChanges = YES;
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ created %@: %@", [super description], self.dateCreated, self.text];
}

#pragma mark - NSCopying
- (instancetype)copyWithZone:(NSZone *)zone
{
    NSData *selfData = [NSKeyedArchiver archivedDataWithRootObject:self];
    DemoNote *newNote = [NSKeyedUnarchiver unarchiveObjectWithData:selfData];
    newNote.hasChanges = YES;
    return newNote;
}

#pragma mark - NSCoding
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init])) {
        _text = [aDecoder decodeObjectForKey:kDemoNoteTextey];
        _dateCreated = [aDecoder decodeObjectForKey:kDemoNoteDateCreatedKey];
        _dateModified = [aDecoder decodeObjectForKey:kDemoNoteDateModifiedKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.text forKey:kDemoNoteTextey];
    [aCoder encodeObject:self.dateCreated forKey:kDemoNoteDateCreatedKey];
    [aCoder encodeObject:self.dateModified forKey:kDemoNoteDateModifiedKey];
}
@end
