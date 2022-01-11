//
//  TTDNSIp.m
//  TTDNS
//
//  Created by 梁金锋 on 2022/1/10.
//

#import "TTDNSIp.h"

@interface TTDNSIp()<NSCopying,NSCoding>

@property (nonatomic, copy) NSString * ipv4;

@property (nonatomic, copy) NSString * ipv6;

@property (nonatomic, copy) NSString * domain;

@end

@implementation TTDNSIp

- (instancetype)initWithIpv4:(NSString *)ipv4 ipv6:(NSString *)ipv6 domain:(NSString *)domain {
    if (self = [super init]) {
        self.ipv4 = ipv4;
        self.ipv6 = ipv6;
        self.domain = domain;
    }
    return self;
}

- (unsigned char *)ipv4Parts {
    
    if (self.ipv4.length > 0) {
        unsigned char *newIP = (unsigned char *)malloc(4);
        NSArray *allParts = [self.ipv4 componentsSeparatedByString:@"."];
        if (allParts.count == 4) { //4个部分组成
            for (int i = 0; i < 4; i ++) {
                NSString *part = [allParts objectAtIndex:i];
                UInt8 partInt = [part intValue];
                newIP[i] = partInt;
            }
            return newIP;
        }
    }
    return nil;
}
- (NSString *)validIpHost {
    if (self.ipv4.length > 0) {
        return self.ipv4;
    }
    if (self.ipv6.length > 0) {
        return [NSString stringWithFormat:@"[%@]",self.ipv6];
    }
    return nil;
}

- (void)updateIpv4:(NSString *)ipv4 andIpv6:(NSString *)ipv6 {
    self.ipv4 = ipv4;
    self.ipv6 = ipv6;
}


#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_ipv4 forKey:@"4"];
    [aCoder encodeObject:_ipv6 forKey:@"6"];
    [aCoder encodeObject:_domain forKey:@"d"];

}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _ipv6 = [aDecoder decodeObjectForKey:@"6"];
         _ipv4 = [aDecoder decodeObjectForKey:@"4"];
        _domain = [aDecoder decodeObjectForKey:@"d"];
    }
    return self;
}

#pragma mark - NSCoping
- (id)copyWithZone:(NSZone *)zone {
    TTDNSIp *copy = [[[self class] allocWithZone:zone] init];
    copy.ipv6 = [self.ipv6 copyWithZone:zone];
    copy.ipv4 = [self.ipv4 copyWithZone:zone];
    copy.domain =[self.domain copyWithZone:zone];
    return copy;
}
@end
