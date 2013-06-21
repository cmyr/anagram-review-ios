//
//  Tweet.h
//  AnagramReviewer
//
//  Created by Colin Rothfels on 2013-06-21.
//  Copyright (c) 2013 cmyr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Hit;

@interface Tweet : NSManagedObject

@property (nonatomic, retain) NSString * hash_str;
@property (nonatomic, retain) NSNumber * id_num;
@property (nonatomic, retain) NSData * profile_img;
@property (nonatomic, retain) NSString * profile_img_url;
@property (nonatomic, retain) NSString * screenname;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSNumber * fetched;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) Hit *hit;

@end
