//
//  ANRTweet.h
//  AnagramReviewer
//
//  Created by Colin Rothfels on 2013-07-19.
//  Copyright (c) 2013 cmyr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ANRTweet : NSObject
@property (nonatomic, retain) NSString * tweetHash;
@property (nonatomic, retain) NSNumber * tweetID;
@property (nonatomic, retain) NSData * profile_img;
@property (nonatomic, retain) NSString * profile_img_url;
@property (nonatomic, retain) NSString * screenname;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * username;
@property (nonatomic) BOOL fetched;
@property (nonatomic) BOOL error;
@property (nonatomic, retain) NSDate * creationDate;
@end
