//
//  Hit+Create.h
//  AnagramReviewer
//
//  Created by Colin Rothfels on 2013-06-19.
//  Copyright (c) 2013 cmyr. All rights reserved.
//

#import "Hit.h"

@interface Hit (Create)

+ (void)hitWithServerInfo:(NSDictionary *)hitDict
         inManagedContext:(NSManagedObjectContext *)context;

@end
