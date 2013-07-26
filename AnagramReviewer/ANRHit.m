//
//  ANRHit.m
//  AnagramReviewer
//
//  Created by Colin Rothfels on 2013-07-19.
//  Copyright (c) 2013 cmyr. All rights reserved.
//

#import "ANRHit.h"
#import "ANRServerHandler.h"
#import "ANRTweet.h"

@implementation ANRHit

-(ANRTweet*)tweet1 {
    if (!_tweet1) _tweet1 = [[ANRTweet alloc]init];
    return _tweet1;
}

-(ANRTweet*)tweet2 {
    if (!_tweet2) _tweet2 = [[ANRTweet alloc]init];
    return _tweet2;
}

+(instancetype)hitFromDict:(NSDictionary *)dict {
    ANRHit *hit = [[ANRHit alloc]init];
    hit.hitID = dict[HIT_ID];
    hit.status = dict[HIT_STATUS];
    hit.rating = @0.0;
    hit.hitHash = dict[@"hash"];
    hit.tweet1.tweetID = [dict valueForKeyPath:TWEET_ONE_ID];
    hit.tweet1.text = [dict valueForKeyPath:TWEET_ONE_TEXT];
    hit.tweet2.tweetID = [dict valueForKeyPath:TWEET_TWO_ID];
    hit.tweet2.text = [dict valueForKeyPath:TWEET_TWO_TEXT];
    return hit;
}

-(BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[ANRHit class]]) {
        ANRHit* otherhit = (ANRHit*)object;
        return [otherhit.hitID isEqual:self.hitID];
    }
    return NO;
}

-(NSUInteger)hash {
    return self.hitID.hash;
}

@end
