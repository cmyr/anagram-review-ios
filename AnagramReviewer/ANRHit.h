//
//  ANRHit.h
//  AnagramReviewer
//
//  Created by Colin Rothfels on 2013-07-19.
//  Copyright (c) 2013 cmyr. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ANRTweet;

@interface ANRHit : NSObject
@property (nonatomic, retain) NSNumber * hitID;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSString * status;
@property (strong, nonatomic) ANRTweet* tweet1;
@property (strong, nonatomic) ANRTweet* tweet2;
@end
