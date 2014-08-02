//
//  acceptBadCerts.h
//  AnagramReviewer
//
//  Created by Colin Rofls on 2014-08-02.
//  Copyright (c) 2014 cmyr. All rights reserved.
//

#ifndef AnagramReviewer_acceptBadCerts_h
#define AnagramReviewer_acceptBadCerts_h
#import <Foundation/Foundation.h>

@interface NSURLRequest(Private)
+(void)setAllowsAnyHTTPSCertificate:(BOOL)inAllow forHost:(NSString *)inHost;
@end

#endif
