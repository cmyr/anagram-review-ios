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
#define TWEET_ONE_ID @"tweet_one.tweet_id"
#define TWEET_TWO_ID @"tweet_two.tweet_id"
#define TWEET_ONE_TEXT @"tweet_one.tweet_text"
#define TWEET_TWO_TEXT @"tweet_two.tweet_text"


#define HIT_STATUS_POST @"posted"
#define HIT_STATUS_REJECT @"rejected"
#define HIT_STATUS_APPROVE @"approved"
#define HIT_STATUS_FAILED @"failed"
#define HIT_STATUS_REVIEW @"review"

#define TWITTER_ID_STRING @"id_str"
#define TWITTER_TEXT @"text"
#define TWITTER_USER_NAME @"user.name"
#define TWITTER_USER_SCREENNAME @"user.screen_name"
#define TWITTER_USER_IMG_URL @"user.profile_image_url"
#define TWITTER_CREATED_DATE @"created_at"
@class STTwitterAPIWrapper;
@class Hit;
@class ANRHit;

@protocol ANRServerDelegateProtocol <NSObject>
-(void)ANRServerFailedWithError:(NSError*)error;
-(void)ANRServerDidReceiveHits:(NSArray*)hits;
-(NSNumber*)lastHitID;
@end

@interface ANRServerHandler : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property id<ANRServerDelegateProtocol> delegate;
//@property (strong, nonatomic) STTwitterAPIWrapper *twitter;
+(instancetype)sharedInstance;
-(void)requestHits;
-(void)addHitToBlacklist:(ANRHit*)hit;
-(void)approveHit:(ANRHit*)hit postImmediately:(BOOL)postNow;
@end
