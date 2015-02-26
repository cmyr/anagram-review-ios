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
@property (strong, nonatomic) NSMutableDictionary *responseDatum;
@property (strong, nonatomic) NSMutableArray *keyList;
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
//        self.responseData = [NSMutableData data];
        self.fetchBatchSize = 15;
    }
    return self;
}

-(NSMutableDictionary*)responseDatum {
    if (!_responseDatum) _responseDatum = [[NSMutableDictionary alloc]init];
    return _responseDatum;
}

-(NSMutableArray*)keyList {
    if (!_keyList) _keyList = [[NSMutableArray alloc]init];
    return _keyList;
}

-(void)requestHits{
//    private method for accepting bad certs

    [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:ANR_HOST];
    NSString *queryString = [NSString stringWithFormat:@"count=%i&status=%@",self.fetchBatchSize, self.delegate.statusToFetch];
    NSNumber *lastHit = [self.delegate lastHitID];

    
    if (lastHit) {
        queryString = [queryString stringByAppendingString:
                       [NSString stringWithFormat:@"&cutoff=%@",[lastHit stringValue]]];
        
    }
    
    queryString = [queryString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString* urlString = [NSString stringWithFormat:@"%@/hits?%@", ANR_BASE_URL, queryString];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request addValue:ANR_AUTH_TOKEN forHTTPHeaderField:@"Authorization"];
    (void)[NSURLConnection connectionWithRequest:request
                                        delegate:self];
    self.responseDatum[request] = [NSMutableData data];
    [self.keyList addObject:request];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}


//-(void)addHitToBlacklist:(ANRHit *)hit {
//    NSString* urlString = [NSString stringWithFormat:@"%@/blacklist?hash=%@", ANR_BASE_URL, hit.hitHash];
//    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
//    [request addValue:ANR_AUTH_TOKEN forHTTPHeaderField:@"Authorization"];
//    (void)[NSURLConnection connectionWithRequest:request
//                                        delegate:self];
//    self.responseDatum[request] = [NSMutableData data];
//    [self.keyList addObject:request];
//}

-(void)markHitsAsSeen:(NSSet *)hitIDs {
    NSArray *hitsArray = [hitIDs allObjects];
    NSString *hitString = [hitsArray componentsJoinedByString:@","];
    NSString* urlString = [NSString stringWithFormat:@"%@/seen?hits=%@", ANR_BASE_URL, hitString];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request addValue:ANR_AUTH_TOKEN forHTTPHeaderField:@"Authorization"];
    (void)[NSURLConnection connectionWithRequest:request
                                        delegate:self];
    self.responseDatum[request] = [NSMutableData data];
    [self.keyList addObject:request];
}

-(void)approveHit:(ANRHit *)hit postImmediately:(BOOL)postNow {
//   NSString *boolString = postNow ? @"true" : @"false";
    NSString* urlString = [NSString stringWithFormat:@"%@/approve?id=%@&post_now=%i", ANR_BASE_URL, [hit.hitID stringValue], postNow];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request addValue:ANR_AUTH_TOKEN forHTTPHeaderField:@"Authorization"];
    (void)[NSURLConnection connectionWithRequest:request
                                        delegate:self];
    self.responseDatum[request] = [NSMutableData data];
    [self.keyList addObject:request];
}

-(void)getInfo {
    [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:ANR_HOST];
    NSString* urlString = [NSString stringWithFormat:@"%@/info?", ANR_BASE_URL];
    NSNumber* lastHit = self.delegate.lastHitID;
    if (lastHit) {
        urlString = [urlString stringByAppendingString:[NSString stringWithFormat:@"last_hit=%@", [lastHit stringValue]]];
    }
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request addValue:ANR_AUTH_TOKEN forHTTPHeaderField:@"Authorization"];
    (void)[NSURLConnection connectionWithRequest:request
                                        delegate:self];

    self.responseDatum[request] = [NSMutableData data];
    [self.keyList addObject:request];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
}


#pragma mark - nsconnectiondelgate methods


-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
//    look for a key in our keyList that matches the request returning
    NSURLRequest *returnedRequest = connection.originalRequest;
    id dataKey;
    for (id key in self.keyList) {
        if ([key isEqual:returnedRequest]){
            dataKey = key;
            break;
        }
    }
    
        NSMutableData *responseData = self.responseDatum[dataKey];
    NSError *jsonError;
    NSDictionary* response = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
    if (jsonError){
        NSLog(@"%@", jsonError);
        [self.delegate ANRServerFailedWithError:jsonError];
        [self.responseDatum removeObjectForKey:dataKey];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        return;
    }
    NSArray* newHits = [response objectForKey:@"hits"];
    if (newHits){
        if ([newHits isKindOfClass:[NSNull class]]){
//            [self.delegate ANRServerDidReceiveHits:nil];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            return;
        }
//        response is a list of hits
        [self processHits:response];
        [self.responseDatum removeObjectForKey:dataKey];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        return;
    }
    NSDictionary *stats = [response objectForKey:@"stats"];
    if (stats) {
        [self.delegate ANRServerDidReceiveInfo:response];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        return;
    }
    [self.delegate ANRServerDidReceiveResponse:response];
}

-(void)processHits:(NSDictionary*)response {
    NSArray *newHits = response[@"hits"];
    NSUInteger serverHitCount = [response[@"total_count"]unsignedIntegerValue];
    NSMutableArray *processedHits = [NSMutableArray array];
    for (NSDictionary* hitDict in newHits) {
        [processedHits addObject:[ANRHit hitFromDict:hitDict]];
    }
    [self.delegate ANRServerDidReceiveHits:processedHits Count:serverHitCount];
    

}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [self.delegate ANRServerFailedWithError:error];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSURLRequest *returnedRequest = connection.originalRequest;
    id dataKey;
    for (id key in self.keyList) {
        if ([key isEqual:returnedRequest]){
            dataKey = key;
            break;
        }
    }
    NSAssert(dataKey, @"assert failed: data key was nil");
    NSMutableData *responseData = self.responseDatum[dataKey];
    [responseData appendData:data];
}

@end
