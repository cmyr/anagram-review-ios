//
//  Tweet+Create.m
//  AnagramReviewer
//
//  Created by Colin Rothfels on 2013-06-19.
//  Copyright (c) 2013 cmyr. All rights reserved.
//

#import "Tweet+Create.h"

@implementation Tweet (Create)

+ (Tweet*)tweetWithID:(NSString *)id_str text:(NSString *)text inContext:(NSManagedObjectContext *)context
{
    Tweet *tweet = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tweet"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"id_num" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"id_num = %@", @([id_str longLongValue])];
    

    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if(!matches || matches.count > 1) {
//TODO: error handling
    } else if (!matches.count) {
        //        no match, so let's create it
        tweet = [NSEntityDescription insertNewObjectForEntityForName:@"Tweet" inManagedObjectContext:context];
        tweet.id_num = @([id_str longLongValue]);
        tweet.text = text;
        // TODO: when do we go to the server to fetch actual stuff?
    } else {
        tweet = matches[0];
    }

    return tweet;
}

+(void)updateTweetWithTwitterInfo:(NSDictionary *)twitterDict inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tweet"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"id_num" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", twitterDict[@"id_str"]];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if(!matches || matches.count > 1) {
 //TODO: error handling
        if (error) NSLog(@"%@", error);
        return;
    } else {
        Tweet *tweet = matches[0];
        tweet.text = twitterDict[@"text"];
        tweet.screenname = [twitterDict valueForKeyPath:@"user.screen_name"];
        tweet.username = [twitterDict valueForKeyPath:@"user.name"];
        tweet.profile_img_url = [twitterDict valueForKeyPath:@"user.profile_img_url"];
        tweet.profile_img = nil;
//        TODO: image fetching
    }
}
@end
