//
//  Hit.h
//  AnagramReviewer
//
//  Created by Colin Rothfels on 2013-06-17.
//  Copyright (c) 2013 cmyr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Tweet;

@interface Hit : NSManagedObject

@property (nonatomic, retain) NSNumber * id_num;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) Tweet *tweet_one;
@property (nonatomic, retain) Tweet *tweet_two;

@end
