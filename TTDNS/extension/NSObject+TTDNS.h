//
//  NSUrlSession+TTDNS.h
//  TTDNS
//
//  Created by 梁金锋 on 2022/1/10.
//

#import <Foundation/Foundation.h>


@interface NSObject(TTDNS)

- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust
                  forDomain:(NSString *)domain;

@end

