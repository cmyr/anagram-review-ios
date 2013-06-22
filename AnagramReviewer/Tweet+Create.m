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
        [tweet addObserver:tweet
                forKeyPath:@"profile_img_url"
                   options:NSKeyValueObservingOptionNew
                   context:NULL];
        
        // TODO: when do we go to the server to fetch actual stuff?
    } else {
        tweet = matches[0];
    }

    return tweet;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
//    means we've received a url from which we need to fetch our image.
    NSString *url = change[NSKeyValueChangeNewKey];
    NSBlockOperation *fetchOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        NSData *imageData = [NSURLConnection sendSynchronousRequest:imageRequest returningResponse:nil error:nil];
        if (imageData) self.profile_img = imageData;
    }];
    [fetchOperation start];
    
}

//+(void)updateTweetWithTwitterInfo:(NSDictionary *)twitterDict inContext:(NSManagedObjectContext *)context
//{
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tweet"];
//    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"id_num" ascending:YES]];
//    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", twitterDict[@"id_str"]];
//    
//    NSError *error = nil;
//    NSArray *matches = [context executeFetchRequest:request error:&error];
//    
//    if(!matches || matches.count > 1) {
// //TODO: error handling
//        if (error) NSLog(@"%@", error);
//        return;
//    } else {
//        Tweet *tweet = matches[0];
//        tweet.text = twitterDict[@"text"];
//        tweet.screenname = [twitterDict valueForKeyPath:@"user.screen_name"];
//        tweet.username = [twitterDict valueForKeyPath:@"user.name"];
//        tweet.profile_img_url = [twitterDict valueForKeyPath:@"user.profile_img_url"];
//        tweet.profile_img = nil;
////        TODO: image fetching
//    }
//}
@end
