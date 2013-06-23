//
//  Tweet+Create.h
//  AnagramReviewer
//
//  Created by Colin Rothfels on 2013-06-19.
//  Copyright (c) 2013 cmyr. All rights reserved.
//

#import "Tweet.h"

@interface Tweet (Create)
+(Tweet*)tweetWithID:(NSString*)id_str
                text:(NSString*)text
           inContext:(NSManagedObjectContext*)context;

-(void)fetchProfileImage;
@end
