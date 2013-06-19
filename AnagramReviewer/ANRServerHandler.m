//
//  AGServerHandler.m
//  Anagrammarian
//
//  Created by Colin Rothfels on 2013-05-17.
//  Copyright (c) 2013 cmyr. All rights reserved.
//

#import "ANRServerHandler.h"
#import "ANRAuth.h"
@interface NSURLRequest(Private)
+(void)setAllowsAnyHTTPSCertificate:(BOOL)inAllow forHost:(NSString *)inHost;
@end

@interface ANRServerHandler ()
@property (strong, nonatomic) NSMutableData* responseData;
@end

@implementation ANRServerHandler


-(id)init{
    if (self = [super init]){
        self.responseData = [NSMutableData data];
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
//- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
//    return YES;
//}
//
//-(void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
//    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
//}
//- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
//    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
//}

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
        [self.delegate AGServerRetrievedHits:newHits];
    }else if ([response objectForKey:@"hit"]){
//        response is a response to a hit modification request
        BOOL successFlag = [response[@"response"]boolValue];
        [self.delegate AGServerDid:successFlag updateStatusForHit:response[@"hit"]];
    }
//    clear responseData to receive another response
    self.responseData = [NSMutableData data];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"error %@", error);
    
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_responseData appendData:data];
}


@end
