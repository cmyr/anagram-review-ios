//
//  STTwitterAppOnly.h
//  STTwitter
//
//  Created by Nicolas Seriot on 3/13/13.
//  Copyright (c) 2013 Nicolas Seriot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STTwitterOAuthProtocol.h"

@interface STTwitterAppOnly : NSObject <STTwitterOAuthProtocol> {
    
}

@property (nonatomic, strong) NSString *consumerKey;
@property (nonatomic, strong) NSString *consumerSecret;
@property (nonatomic, strong) NSString *bearerToken;

+ (NSString *)base64EncodedBearerTokenCredentialsWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret;

- (void)invalidateBearerTokenWithSuccessBlock:(void(^)())successBlock
                                   errorBlock:(void(^)(NSError *error))errorBlock;

@end
