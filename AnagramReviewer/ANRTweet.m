//
//  ANRTweet.m
//  AnagramReviewer
//
//  Created by Colin Rothfels on 2013-07-19.
//  Copyright (c) 2013 cmyr. All rights reserved.
//

#import "ANRTweet.h"
#import "ANRServerHandler.h"

@implementation ANRTweet

-(void)updateWithTwitterInfo:(NSDictionary *)twitterInfo {
//    correct encoded characters
    NSString *tweetText = [twitterInfo[TWITTER_TEXT] stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    tweetText = [tweetText stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    tweetText = [tweetText stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    
    self.text = tweetText;
    self.screenname = [@"@" stringByAppendingString:[twitterInfo valueForKeyPath:TWITTER_USER_SCREENNAME]];
    self.username = [twitterInfo valueForKeyPath:TWITTER_USER_NAME];
    self.profile_img_url = [twitterInfo valueForKeyPath:TWITTER_USER_IMG_URL];
    self.creationDate = [self dateFromString:[twitterInfo valueForKey:TWITTER_CREATED_DATE]];
    self.fetched = YES;
    [self fetchProfileImage];
}

-(void)updateFailedWitheError:(NSError *)error {
    NSLog(@"breaking to chill: %@", error);
    if (error.code == 404 || error.code == 403) {
        self.error = YES;
        self.fetched = YES;
    }
}

-(NSDate*)dateFromString:(NSString*)string{
    //    Wed Aug 27 13:08:45 +0000 2008
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"EEE MMM dd HH:mm:ss Z Y"];
    return [dateFormatter dateFromString:string];
}

-(void)fetchProfileImage
{
    NSString *url = self.profile_img_url;
    url = [url stringByReplacingOccurrencesOfString:@"_normal" withString:@"_bigger"];
    NSBlockOperation *fetchOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        NSData *imageData = [NSURLConnection sendSynchronousRequest:imageRequest returningResponse:nil error:nil];
        
        if (imageData){
            self.profile_img = [UIImage imageWithData:imageData];
        }
    }];
    [fetchOperation start];
    
}

@end
