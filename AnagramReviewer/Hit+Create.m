//
//  Hit+Create.m
//  AnagramReviewer
//
//  Created by Colin Rothfels on 2013-06-19.
//  Copyright (c) 2013 cmyr. All rights reserved.
//

#import "Hit+Create.h"
#import "ANRServerHandler.h"
#import "Tweet+Create.h"

@implementation Hit (Create)

+ (void)hitWithServerInfo:(NSDictionary *)hitDict inManagedContext:(NSManagedObjectContext *)context
{
    Hit *hit = nil;
//    check to see if this hit is already stored;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Hit"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"status" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"id_num = %@", hitDict[HIT_ID]];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if(!matches || matches.count > 1) {
#warning here be errors
    } else if (!matches.count) {
//        no match, so let's create it
        hit = [NSEntityDescription insertNewObjectForEntityForName:@"Hit" inManagedObjectContext:context];
        hit.id_num = hitDict[HIT_ID];
        hit.status = hitDict[HIT_STATUS];
        hit.rating = @0.0f;
        Tweet *tweetOne = [Tweet tweetWithID:[hitDict valueForKeyPath:TWEET_ONE_ID]
                                      text:[hitDict valueForKeyPath:TWEET_ONE_TEXT]
                                 inContext:context];
        Tweet *tweetTwo = [Tweet tweetWithID:[hitDict valueForKeyPath:TWEET_TWO_ID]
                                      text:[hitDict valueForKeyPath:TWEET_TWO_TEXT]
                                 inContext:context];
        hit.tweets = [NSSet setWithObjects:tweetOne, tweetTwo, nil];
    } else {
        hit = matches[0];
    }
}

@end
