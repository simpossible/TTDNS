//
//  NSURL+TTDNS.m
//  TTDNS
//
//  Created by 梁金锋 on 2022/1/10.
//

#import "NSURL+TTDNS.h"
#import <objc/message.h>
#import "TTDNS.h"

static char ttdns_url;

@implementation NSURL(TTDNS)

+(void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method fromMethod = class_getClassMethod(self, @selector(URLWithString:));
        Method toMethod = class_getClassMethod(self, @selector(TTDNS_URLWithString:));
        method_exchangeImplementations(toMethod, fromMethod);
    });
}
+ (instancetype)TTDNS_URLWithString:(NSString *)URLString {
    TTDNSIp *ip  = nil;
    URLString = [[TTDNS shared] urlStringWith:URLString dnsIP:&ip];
    NSURL *url = [self TTDNS_URLWithString:URLString];
    url.dnsIp = ip;
    return url;
}

- (void)setDnsIp:(TTDNSIp *)dnsIp {
    objc_setAssociatedObject(self, &ttdns_url, dnsIp, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TTDNSIp *)dnsIp {
    return objc_getAssociatedObject(self, &ttdns_url);
}



@end
