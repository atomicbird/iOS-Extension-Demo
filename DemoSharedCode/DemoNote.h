//
//  DemoNote.h
//  DemoNotes
//
//  Created by Tom Harrington on 11/25/14.
//  Copyright (c) 2014 Atomic Bird LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DemoNote : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSDate * dateModified;

@end
