//
//  TTDNSTencentLoader.h
//  TTDNS
//
//  Created by 梁金锋 on 2022/1/13.
//

#import "TTDNSLoader.h"

NS_ASSUME_NONNULL_BEGIN
@class HttpDnsService;

@interface TTDNSAliLoader : TTDNSLoader

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithService:(HttpDnsService *)httpdns;

@end

NS_ASSUME_NONNULL_END
