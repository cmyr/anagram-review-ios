//
//  AGServerHandler.m
//  Anagrammarian
//
//  Created by Colin Rothfels on 2013-05-17.
//  Copyright (c) 2013 cmyr. All rights reserved.
//

#import "ANRServerHandler.h"
#import "ANRAuth.h"
#import "STTwitterAPIWrapper.h"
#import "Hit+Create.h"


@interface NSURLRequest(Private)
+(void)setAllowsAnyHTTPSCertificate:(BOOL)inAllow forHost:(NSString *)inHost;
@end

@interface ANRServerHandler ()
@property (strong, nonatomic) NSMutableData* responseData;
@property (strong, nonatomic) STTwitterAPIWrapper *twitter;
@end

@implementation ANRServerHandler


-(id)init{
    if (self = [super init]){
        self.responseData = [NSMutableData data];
//        set up twitter handler:
        self.twitter = [STTwitterAPIWrapper twitterAPIWithOAuthConsumerName:@"name?"
                                                                consumerKey:TWITTER_CONSUMER_KEY
                                                             consumerSecret:TWITTER_CONSUMER_SECRET
                                                                 oauthToken:TWITTER_ACCESS_KEY
                                                           oauthTokenSecret:TWITTER_ACCESS_SECRET];
        [self.twitter verifyCredentialsWithSuccessBlock:^(NSString *username) {
            NSLog(@"successfully logged into twitter with as %@", username);
        } errorBlock:^(NSError *error) {
            [self.delegate AGServerFailedWithError:error];
        }];

    }
    return self;
}


-(void)requestHits{
//    private method for accepting bad certs
    [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:@"h.cmyr.net"];
    NSString* urlString = [NSString stringWithFormat:@"%@/hits", ANR_BASE_URL];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request addValue:ANR_AUTH_TOKEN forHTTPHeaderField:@"Authorization"];
    (void)[NSURLConnection connectionWithRequest:request
                                        delegate:self];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

-(void)setStatus:(NSString *)status forHit:(NSDictionary *)hit{
    NSString* urlString = [NSString stringWithFormat:@"%@/mod?id=%@&status=%@",ANR_BASE_URL, hit[@"id"], status];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request addValue:ANR_AUTH_TOKEN forHTTPHeaderField:@"Authorization"];
    (void)[NSURLConnection connectionWithRequest:request
                                        delegate:self];
}

-(void)postHit:(NSDictionary *)hit{
    [self setStatus:@"post" forHit:hit];
}

#pragma mark - nsconnectiondelgate methods

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
//    find out what exactly we received;
    NSError *jsonError;
    NSDictionary* response = [NSJSONSerialization JSONObjectWithData:self.responseData options:0 error:&jsonError];
    if (jsonError){
        NSLog(@"%@", jsonError);
        [self.delegate AGServerFailedWithError:jsonError];
        return;
    }
    NSArray* newHits = [response objectForKey:@"hits"];
    if (newHits){
//        response is a list of hits
        [self processHits:newHits];
    }else if ([response objectForKey:@"hit"]){
//        response is a response to a hit modification request
        BOOL successFlag = [response[@"response"]boolValue];
        [self.delegate AGServerDid:successFlag updateStatusForHit:response[@"hit"]];
    }
//    clear responseData to receive another response
    self.responseData = [NSMutableData data];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

-(void)processHits:(NSArray*)newHits {
    NSUInteger fetchRequestCount = 0;
    for (NSDictionary* newHit in newHits) {
//        make the Hit database object;
           Hit* hit = [Hit hitWithServerInfo:newHit inManagedContext:self.delegate.managedObjectContext];
//        fetch the first tweet;
        if (hit.fetched) continue;
//        because tweets is a set, i'm fetching both even if maybe only one needs it. not super efficient, I acknowledge.
        [self.twitter getStatusWithID:[newHit valueForKeyPath:TWEET_ONE_ID]
                      includeEntities:YES
                         successBlock:^(NSDictionary *status) {
                             [hit updateWithTwitterInfo:status];
                         } errorBlock:^(NSError *error) {
                             [hit twitterUpdateFailedWithError:error];
                         }];
//        fetch second tweet
        [self.twitter getStatusWithID:[newHit valueForKeyPath:TWEET_TWO_ID]
                      includeEntities:YES
                         successBlock:^(NSDictionary *status) {
                             [hit updateWithTwitterInfo:status];
                         } errorBlock:^(NSError *error) {
                             [hit twitterUpdateFailedWithError:error];
                         }];
        fetchRequestCount++;
    }
    NSLog(@"%i fetch requests made", fetchRequestCount);
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"error %@", error);
    
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_responseData appendData:data];
}


@end
