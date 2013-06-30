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

+ (Hit*)hitWithServerInfo:(NSDictionary *)hitDict inManagedContext:(NSManagedObjectContext *)context
{
//        creates and sets up a hit from info, as necessary.
    Hit *hit = nil;
//    check to see if this hit is already stored;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Hit"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"status" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"id_num = %@", hitDict[HIT_ID]];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if(!matches || matches.count > 1) {
    //TODO: error handling?
        
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
    return hit;
}


-(void)updateWithTwitterInfo:(NSDictionary *)twitterInfo
{
    Tweet* tweet;
    for (Tweet *t in self.tweets) {
        if ([[t.id_num stringValue]isEqualToString:twitterInfo[TWITTER_ID_STRING]]) tweet = t;
    }
//    assert(tweet);
    if (!tweet)
        NSLog(@"no tweet!");
    NSLog(@"successfully fetched tweet: %@", tweet.id_num);
    tweet.text = twitterInfo[TWITTER_TEXT];
    tweet.screenname = [twitterInfo valueForKeyPath:TWITTER_USER_SCREENNAME];
    tweet.username = [twitterInfo valueForKeyPath:TWITTER_USER_NAME];
    tweet.profile_img_url = [twitterInfo valueForKeyPath:TWITTER_USER_IMG_URL];
    tweet.created_at = [self dateFromString:[twitterInfo valueForKey:TWITTER_CREATED_DATE]];
    tweet.fetched = @(YES);
    
//    check that to see if all tweets are fetched
    self.fetched = @(YES);
    for (Tweet *t in self.tweets) {
        if (!t.fetched) self.fetched = @(NO);
    }
}

-(NSDate*)dateFromString:(NSString*)string{
//    Wed Aug 27 13:08:45 +0000 2008
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"EEE MMM dd HH:mm:ss Z Y"];
    return [dateFormatter dateFromString:string];
}

-(void)twitterUpdateFailedWithError:(NSError *)error
{
    NSLog(@"twitter update failed with Error: %@ for hit: %@", error, self);
}

@end
