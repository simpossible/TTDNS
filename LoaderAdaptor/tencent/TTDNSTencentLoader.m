//
//  TTDNSTencentLoader.m
//  TTDNS
//
//  Created by 梁金锋 on 2022/1/13.
//

#import "TTDNSTencentLoader.h"
#import <MSDKDns_C11/MSDKDns.h>

@implementation TTDNSTencentLoader

- (void)preLoadDNS:(NSArray<NSString *> *)hosts {
 
}

- (TTDNSIp *_Nullable)getIpByDomain:(NSString * _Nullable)domain {
    if (domain.length > 0) {
        return [self generateIpWithArray:[[MSDKDns sharedInstance] WGGetHostByName: domain] domain:domain];
    }
    return nil;
}

/// 异步获取域名
- (void)getIpForDomain:(NSString * _Nullable)domain async:(void (^_Nullable)(TTDNSIp * _Nullable ip))handler {
    [[MSDKDns sharedInstance] WGGetHostByNameAsync:domain returnIps:^(NSArray *ipsArray) {
        handler?handler([self generateIpWithArray:ipsArray domain:domain]):nil;
    }];
}

/// 一步批量获取域名
- (void)getIpForDomains:(NSArray<NSString *> * _Nullable)domains async:(void (^_Nullable)(NSArray<TTDNSIp *> * _Nullable ips))handler {
    if (domains.count == 0) {
        handler?handler(@[]):nil;
        return;
    }
    [[MSDKDns sharedInstance] WGGetHostsByNamesAsync:domains returnIps:^(NSDictionary *ipsDictionary) {
        NSMutableArray *array = [NSMutableArray array];
        for (NSString*key in ipsDictionary.allKeys) {
            NSArray *ipsArray = ipsDictionary[key];
            TTDNSIp *ip = [self generateIpWithArray:ipsArray domain:key];
            if (ip) {
                [array addObject:ip];
            }
        }
        handler?handler(array):nil;
    }];
}

- (TTDNSIp *)generateIpWithArray:(NSArray *)ipsArray domain:(NSString*)domain {
    if (ipsArray && ipsArray.count > 1 && domain.length >0) {
        NSString *ipv4 = ipsArray[0];
        NSString *ipv6 = ipsArray[1];
        ipv4 = [ipv4 isEqualToString:@"0"]?@"":ipv4;
        ipv6 = [ipv6 isEqualToString:@"0"]?@"":ipv6;
        if (ipv4.length > 0 || ipv6.length > 0) {
            return [[TTDNSIp alloc] initWithIpv4:ipv4 ipv6:ipv6 domain:domain];
        }
    }
    return nil;
}

@end
