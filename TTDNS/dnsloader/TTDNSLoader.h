//
//  TTDNSLoader.h
//  TTDNS
//
//  Created by 梁金锋 on 2022/1/13.
//

#import <Foundation/Foundation.h>
#import "TTDNSIp.h"

@interface TTDNSLoader : NSObject

- (void)preLoadDNS:(NSArray<NSString *> *_Nullable)hosts;

/// 同步的方式请求一个域名的解析
- (TTDNSIp *_Nullable)getIpByDomain:(NSString * _Nullable)domain;

/// 异步获取域名
- (void)getIpForDomain:(NSString * _Nullable)domain async:(void (^_Nullable)(TTDNSIp * _Nullable ip))handler;

/// 一步批量获取域名
- (void)getIpForDomains:(NSArray<NSString *> * _Nullable)domains async:(void (^_Nullable)(NSArray<TTDNSIp *> * _Nullable ips))handler;

@end

