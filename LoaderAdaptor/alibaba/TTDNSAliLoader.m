//
//  TTDNSTencentLoader.m
//  TTDNS
//
//  Created by 梁金锋 on 2022/1/13.
//

#import "TTDNSAliLoader.h"
#import <AlicloudHttpDNS/AlicloudHttpDNS.h>

@interface TTDNSAliLoader()

@property (nonatomic, strong) HttpDnsService * httpdns;

@end

@implementation TTDNSAliLoader

- (instancetype)initWithService:(HttpDnsService *)httpdns {
    if (!httpdns) {
        return nil;
    }
    if (self = [super init]) {
        self.httpdns = httpdns;
    }
    return self;
}

- (void)preLoadDNS:(NSArray<NSString *> *)hosts {
    [self.httpdns setPreResolveHosts:hosts];
}


/// 同步获取接口
- (TTDNSIp *_Nullable)getIpByDomain:(NSString * _Nullable)domain {
    if (domain.length > 0) {
        NSString *ipv4 = [self.httpdns getIpByHostAsync:domain];
        NSString *ipv6 = [self.httpdns getIPv6ByHostAsync:domain];;
        ipv4 = ipv4?:@"";
        ipv6 = ipv6?:@"";
        if (ipv4.length > 0 || ipv6.length > 0) {
            return [[TTDNSIp alloc] initWithIpv4:ipv4 ipv6:ipv6 domain:domain];
        }
    }
    return nil;
}

/// 异步获取域名
- (void)getIpForDomain:(NSString * _Nullable)domain async:(void (^_Nullable)(TTDNSIp * _Nullable ip))handler {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (domain.length > 0) {
            TTDNSIp *ip = [self getIpByDomain:domain];
            handler?handler(ip):nil;
        }
        handler?handler(nil):nil;
    });
}

/// 一步批量获取域名
- (void)getIpForDomains:(NSArray<NSString *> * _Nullable)domains async:(void (^_Nullable)(NSArray<TTDNSIp *> * _Nullable ips))handler {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (domains.count == 0) {
            handler?handler(@[]):nil;
            return;
        }
        NSMutableArray *array = [NSMutableArray array];
        for (NSString *domain in domains) {
            TTDNSIp *ip = [self getIpByDomain:domain];
            ip?[array addObject:ip]:nil;
        }
        handler?handler(array):nil;
    });
}


@end
