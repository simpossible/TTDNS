//
//  NSMutableURLRequest+TTDNS.m
//  TTDNS
//
//  Created by 梁金锋 on 2022/1/10.
//

#import "NSMutableURLRequest+TTDNS.h"
#import <objc/message.h>
#import "NSURL+TTDNS.h"


@implementation NSURLRequest(TTDNS)

+(void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method fromMethod = class_getClassMethod(self, @selector(TTDNS_RequestWithURL:));
        Method toMethod = class_getClassMethod(self, @selector(requestWithURL:));
        method_exchangeImplementations(toMethod, fromMethod);
        
        fromMethod = class_getClassMethod(self, @selector(TTDNSRequestWithURL:cachePolicy:timeoutInterval:));
        toMethod = class_getClassMethod(self, @selector(requestWithURL:cachePolicy:timeoutInterval:));
        method_exchangeImplementations(toMethod, fromMethod);
    });
}

+ (instancetype)TTDNS_RequestWithURL:(NSURL *)URL {
    
    NSMutableURLRequest *mutableReq = [self TTDNS_RequestWithURL:URL];
    if (URL.dnsIp && URL.dnsIp.domain.length > 0 && [mutableReq isKindOfClass:[NSMutableURLRequest class]]) {
        [mutableReq setValue:URL.dnsIp.domain forHTTPHeaderField:@"host"];
    }
    return mutableReq;
}


+ (instancetype)TTDNSRequestWithURL:(NSURL *)URL cachePolicy:(NSURLRequestCachePolicy)cachePolicy timeoutInterval:(NSTimeInterval)timeoutInterval {
    NSMutableURLRequest *mutableReq = [self TTDNSRequestWithURL:URL cachePolicy:cachePolicy timeoutInterval:timeoutInterval];
    if (URL.dnsIp && URL.dnsIp.domain.length > 0 && [mutableReq isKindOfClass:[NSMutableURLRequest class]]) {
        [mutableReq setValue:URL.dnsIp.domain forHTTPHeaderField:@"host"];
    }
    return mutableReq;
}
@end


