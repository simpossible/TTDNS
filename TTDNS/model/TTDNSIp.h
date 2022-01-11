//
//  TTDNSIp.h
//  TTDNS
//
//  Created by 梁金锋 on 2022/1/10.
//

#import <Foundation/Foundation.h>



@interface TTDNSIp : NSObject

@property (nonatomic, copy, readonly) NSString * ipv4;

@property (nonatomic, copy, readonly) NSString * ipv6;

@property (nonatomic, copy, readonly) NSString * domain;

- (instancetype)initWithIpv4:(NSString *)ipv4 ipv6:(NSString *)ipv6 domain:(NSString *)domain;

/// ipv4 4个部分
- (unsigned char *)ipv4Parts;


- (NSString *)validIpHost;
@end

