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
#import "ANRHit.h"


@interface NSURLRequest(Private)
+(void)setAllowsAnyHTTPSCertificate:(BOOL)inAllow forHost:(NSString *)inHost;
@end

@interface ANRServerHandler ()
@property (strong, nonatomic) NSMutableData* responseData;
@property (strong, nonatomic) NSMutableDictionary *hitsAwaitingResponses;
@end

@implementation ANRServerHandler

+(instancetype)sharedInstance {
    static ANRServerHandler *singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[ANRServerHandler alloc]init];
    });
    return singleton;
}

-(id)init{
    if (self = [super init]){
        self.responseData = [NSMutableData data];
    }
    return self;
}

-(NSMutableDictionary*)hitsAwaitingResponses {
    if (!_hitsAwaitingResponses) _hitsAwaitingResponses = [[NSMutableDictionary alloc]init];
    return _hitsAwaitingResponses;
}

-(void)requestHits{
//    private method for accepting bad certs
    NSUInteger count = 15;
    [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:@"h.cmyr.net"];
    NSString *queryString = [NSString stringWithFormat:@"count=%i",count];
    NSNumber *lastHit = [self.delegate lastHitID];
    if (lastHit){
        queryString = [queryString stringByAppendingString:
                       [NSString stringWithFormat:@"&older_than=%@",[lastHit stringValue]]];
        
    }
    queryString = [queryString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString* urlString = [NSString stringWithFormat:@"%@/2.0/hits?%@", ANR_BASE_URL, queryString];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request addValue:ANR_AUTH_TOKEN forHTTPHeaderField:@"Authorization"];
    (void)[NSURLConnection connectionWithRequest:request
                                        delegate:self];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}


-(void)addHitToBlacklist:(ANRHit *)hit {
    NSString* urlString = [NSString stringWithFormat:@"%@/blacklist?hash=%@", ANR_BASE_URL, hit.hitHash];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request addValue:ANR_AUTH_TOKEN forHTTPHeaderField:@"Authorization"];
    (void)[NSURLConnection connectionWithRequest:request
                                        delegate:self];
}

-(void)approveHit:(ANRHit *)hit postImmediately:(BOOL)postNow {
    NSString* urlString = [NSString stringWithFormat:@"%@/approve?id=%@&post_now=%i", ANR_BASE_URL, [hit.hitID stringValue], postNow];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request addValue:ANR_AUTH_TOKEN forHTTPHeaderField:@"Authorization"];
    (void)[NSURLConnection connectionWithRequest:request
                                        delegate:self];
}

//-(void)setStatus:(NSString *)status forHit:(Hit *)hit{
//    NSString* urlString = [NSString stringWithFormat:@"%@/mod?id=%@&status=%@",ANR_BASE_URL, hit.id_num, status];
//    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
//    [request addValue:ANR_AUTH_TOKEN forHTTPHeaderField:@"Authorization"];
//    (void)[NSURLConnection connectionWithRequest:request
//                                        delegate:self];
//    self.hitsAwaitingResponses[hit.id_num] = hit;
//}

//-(void)postHit:(Hit *)hit{
//    [self setStatus:HIT_STATUS_POST forHit:hit];
//}
//
//-(void)rejectHit:(Hit *)hit {
//    [self setStatus:HIT_STATUS_REJECT forHit:hit];
//    
//}
//
//-(void)approveHit:(Hit*)hit {
//    [self setStatus:HIT_STATUS_APPROVE forHit:hit];
//}

#pragma mark - nsconnectiondelgate methods

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
//    find out what exactly we received;
    NSError *jsonError;
    NSDictionary* response = [NSJSONSerialization JSONObjectWithData:self.responseData options:NSJSONReadingAllowFragments error:&jsonError];
    if (jsonError){
        NSLog(@"%@", jsonError);
        [self.delegate ANRServerFailedWithError:jsonError];
        self.responseData = [NSMutableData data];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        return;
    }
    NSArray* newHits = [response objectForKey:@"hits"];
    if (newHits){
//        response is a list of hits
        [self processHits:newHits];
//    }else if ([response objectForKey:@"hit"]){
////        response is a response to a hit modification request
//        BOOL success = [response[@"response"]boolValue];
//        Hit *hit = self.hitsAwaitingResponses[response[@"hit"][HIT_ID]];
//        [self.delegate AGServerDid:success updateStatus:response[@"hit"][HIT_STATUS] ForHit:hit];
//    }
//    clear responseData to receive another response
    self.responseData = [NSMutableData data];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

-(void)processHits:(NSArray*)newHits {
    NSMutableArray *processedHits = [NSMutableArray array];
    for (NSDictionary* hitDict in newHits) {
        [processedHits addObject:[ANRHit hitFromDict:hitDict]];
    }
    [self.delegate ANRServerDidReceiveHits:processedHits];
    
    
//    NSUInteger fetchRequestCount = 0;
//    NSMutableSet *hitIDs = [NSMutableSet set];
//    NSUInteger oldCount = 0;
//    
//    for (NSDictionary* newHit in newHits) {
//        [hitIDs addObject: [newHit valueForKeyPath:HIT_ID]];
//    }
//    //    delete from data tweets anything that wasn't returned from the server;
//    //    so what do we want to do? mostly just fetch any tweet that has an ID outside of our list
//    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Hit"];
//    NSError *error;
//    NSArray *results = [self.delegate.managedObjectContext executeFetchRequest:request error:&error];
//    if (error)
//        NSLog(@"error fetching hits for removal: %@", error);
//    if (!results)
//        NSLog(@"error fetching hits returned nil?");
//    for (Hit* hit in results) {
//        NSLog(@"hit ID: %@", hit.id_num);
////        NSLog(@"hit status: %@", hit.fetched);
//        if (![hitIDs containsObject:hit.id_num]){
//            [self.delegate.managedObjectContext deleteObject:hit];
//        }else {
//            oldCount ++;
//        }
//    }
//    
////    [self.delegate AGServerDidReceiveHits:newHits.count New:(newHits.count - oldCount)];
//    [self.delegate.managedObjectContext save:&error];
//    if (error) NSLog(@"saving error: %@", error);
//
////    now actually go through our received hits and update them as needed
//    for (NSDictionary* newHit in newHits) {
////        make the Hit database object;
//           Hit* hit = [Hit hitWithServerInfo:newHit inManagedContext:self.delegate.managedObjectContext];
//        [hitIDs addObject:hit.id_num];
////        fetch the first tweet;
//        NSLog(@"hit status: %@", hit.fetched);
//        if ([hit.fetched boolValue]) continue;
////        because tweets is a set, i'm fetching both even if maybe only one needs it. not super efficient, I acknowledge.
//        [self.twitter getStatusWithID:[newHit valueForKeyPath:TWEET_ONE_ID]
//                      includeEntities:YES
//                         successBlock:^(NSDictionary *status) {
//                             [hit updateWithTwitterInfo:status];
//                         } errorBlock:^(NSError *error) {
//                             [hit twitterUpdateFailedWithError:error];
//                         }];
////        fetch second tweet
//        [self.twitter getStatusWithID:[newHit valueForKeyPath:TWEET_TWO_ID]
//                      includeEntities:YES
//                         successBlock:^(NSDictionary *status) {
//                             [hit updateWithTwitterInfo:status];
//                         } errorBlock:^(NSError *error) {
//                             [hit twitterUpdateFailedWithError:error];
//                         }];
//        fetchRequestCount++;
//    }
//    NSLog(@"%i fetch requests made", fetchRequestCount);
//    
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"error %@", error);
    
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_responseData appendData:data];
}


@end
