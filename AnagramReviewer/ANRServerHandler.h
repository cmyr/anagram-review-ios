//
//  AGServerHandler.h
//  Anagrammarian
//
//  Created by Colin Rothfels on 2013-05-17.
//  Copyright (c) 2013 cmyr. All rights reserved.
//

#import <Foundation/Foundation.h>


#define HIT_ID @"id"
#define HIT_STATUS @"status"
#define TWEET_ONE_ID @"tweet_one.id"
#define TWEET_TWO_ID @"tweet_two.id"
#define TWEET_ONE_TEXT @"tweet_one.text"
#define TWEET_TWO_TEXT @"tweet_two.text"


#define HIT_STATUS_REVIEW @"review"
#define HIT_STATUS_APPROVED @"approved"
#define HIT_STATUS_FAILED @"failed"

@protocol ANRServerDelegateProtocol <NSObject>
-(void)AGServerRetrievedHits:(NSArray*)hits;
-(void)AGServerDid:(BOOL)successFlag updateStatusForHit:(NSDictionary*)hit;
-(void)AGServerFailedWithError:(NSError*)error;
@end

@interface ANRServerHandler : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property id<ANRServerDelegateProtocol> delegate;

-(void)requestHits;
-(void)setStatus:(NSString*)status forHit:(NSDictionary*)hit;
-(void)postHit:(NSDictionary*)hit;


@end
