//
//  Hit.h
//  AnagramReviewer
//
//  Created by Colin Rothfels on 2013-06-19.
//  Copyright (c) 2013 cmyr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Tweet;

@interface Hit : NSManagedObject

@property (nonatomic, retain) NSNumber * id_num;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSSet *tweets;
@end

@interface Hit (CoreDataGeneratedAccessors)

- (void)addTweetsObject:(Tweet *)value;
- (void)removeTweetsObject:(Tweet *)value;
- (void)addTweets:(NSSet *)values;
- (void)removeTweets:(NSSet *)values;

@end
