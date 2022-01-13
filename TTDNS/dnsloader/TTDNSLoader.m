//
//  TTDNSLoader.m
//  TTDNS
//
//  Created by 梁金锋 on 2022/1/13.
//

#import "TTDNSLoader.h"

@implementation TTDNSLoader

- (void)preLoadDNS:(NSArray<NSString *> *)hosts {
    
}

- (TTDNSIp *_Nullable)getIpByDomain:(NSString * _Nullable)domain {
    return nil;
}

/// 异步获取域名
- (void)getIpForDomain:(NSString * _Nullable)domain async:(void (^_Nullable)(TTDNSIp * _Nullable ip))handler {
    
}

/// 一步批量获取域名
- (void)getIpForDomains:(NSArray<NSString *> * _Nullable)domains async:(void (^_Nullable)(NSArray<TTDNSIp *> * _Nullable ips))handler {
    
}

@end
