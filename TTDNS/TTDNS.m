//
//  TTDNS.m
//  Pods-TTDNS
//
//  Created by ZERO-M1 on 2021/6/2.
//

#import "TTDNS.h"
@import CFNetwork;
@import dnssd;
#include <arpa/inet.h>

#include <netdb.h>
#include <dns_sd.h>
#import <objc/runtime.h>
#import <MSDKDns_C11/MSDKDns.h>
@import AFNetworking;

@interface TTDNSIp();
- (void)updateIpv4:(NSString *)ipv4 andIpv6:(NSString *)ipv6;
@end

@interface TTDNS()<NSURLSessionDelegate>


@property (nonatomic, strong) NSMutableSet<NSString *> * whiteListsDic;

@property (nonatomic, strong) NSMutableDictionary<NSString *,TTDNSIp *> * ipParseCache;

@property (nonatomic) dispatch_queue_t ioQueue;

@property (nonatomic, strong) NSMutableDictionary * domainReqTimes;

@end

@implementation TTDNS

// 在高版本系统已经不适用了。之后想办法
//+ (void)load {
//    [Log info:@"TTDNS" message:@"请注意 DNSServiceGetAddrInfo 进行了方法替换"];
//    DobbyHook((void *)DNSServiceGetAddrInfo, (void *)my_DNSServiceGetAddrInfo, (void **)&origin_DNSServiceGetAddrInfo);
//}

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static TTDNS * sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TTDNS alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.whiteListsDic = [NSMutableSet set];
        self.ipParseCache = [NSMutableDictionary dictionary];
        self.ioQueue = dispatch_queue_create("msgDeal", DISPATCH_QUEUE_SERIAL);
        self.domainReqTimes = [NSMutableDictionary dictionary];
        [self loadLocalCache];
    }
    return self;
}

- (void)loadLocalCache {
    
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"tt_dns_cache"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        dispatch_async(self.ioQueue, ^{
            NSData *data = [NSData dataWithContentsOfFile:path];
            NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
            NSDictionary *dics = [unarchiver decodeObjectForKey:@"dns"];// initWithCoder方法被调用
            [unarchiver finishDecoding];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self onLocalDns:dics];
            });
        });
    }
}

- (void)onLocalDns:(NSDictionary *)dic {
    for (NSString *key in dic.allKeys) {
        TTDNSIp *exist = [self.ipParseCache objectForKey:key];
        if (!exist) {//如果当前的缓存没有那么就加入
            [self.ipParseCache setObject:[dic objectForKey:key] forKey:key];
        }
    }
}

- (void)saveDns {
    NSDictionary *dic = [self.ipParseCache copy];
    dispatch_async(self.ioQueue, ^{
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"tt_dns_cache"];
        NSMutableData *data = [[NSMutableData alloc] init];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [archiver encodeObject:dic forKey:@"dns"]; // archivingDate的encodeWithCoder
        //    方法被调用
        [archiver finishEncoding];
        [data writeToFile:path atomically:YES];
    });
}

- (BOOL)isDomainInWhiteList:(NSString *)domain {
    return [self.whiteListsDic containsObject:domain];
}

/// 增加白名单的域名
- (void)addWhiteListDomain:(NSString *)domain {
    if (domain && [domain isKindOfClass:[NSString class]]) {
        if (![self.whiteListsDic containsObject:domain]) {
            [self.whiteListsDic addObject:domain];
            [self reloadIpForDomain:domain];
        }
    }
    
}



/// 批量增加白名单的域名
- (void)addWhiteListDomains:(NSArray<NSString *> *)domains {
    if ([domains isKindOfClass:[NSArray class]]) {
        [self.whiteListsDic addObjectsFromArray:domains];
        [self getIpForDomains:domains async:nil];///刷新一次所有的ip
    }
}

/// 全量刷新域名
- (void)refreshWhiteListDomains:(NSArray<NSString *> *)domains {
    if ([domains isKindOfClass:[NSArray class]]) {
        [self.whiteListsDic removeAllObjects];
        [self.whiteListsDic addObjectsFromArray:domains];
        [self getIpForDomains:domains async:nil];
    }
}

/// 从缓存获取一个域名的解析 如果获取不到进行刷新
- (TTDNSIp *)ipByDomain:(NSString *)domain {
    if (domain.length > 0) {
        TTDNSIp *ip = [self.ipParseCache objectForKey:domain];
        [self reloadIpForDomain:domain];
        return ip;

    }
    return nil;
}

/// 同步 通过网络请求 获取域名解析
- (TTDNSIp *)getIpByDomain:(NSString *)domain {
    if (domain) {
        // 单个域名查询
        NSArray *ipsArray = [[MSDKDns sharedInstance] WGGetHostByName: domain];
        BOOL refresh;
        TTDNSIp *ip = [self generateIpWithArray:ipsArray domain:domain isRefresh:&refresh];
        if (!ip) {
            if (domain.length > 0) {
                [self reloadIpForDomain:domain];
            }
        }else{
            if (refresh) {
                [self saveDns];
            }
        }
        return ip;
        
    }
    return nil;
}

/// 通过一个数组生成一个ip array[0] = ipv4 array[1] = ipv6
- (TTDNSIp *)generateIpWithArray:(NSArray *)ipsArray domain:(NSString*)domain isRefresh:(BOOL *)refresh {
    if (ipsArray && ipsArray.count > 1 && domain.length >0) {
        NSString *ipv4 = ipsArray[0];
        NSString *ipv6 = ipsArray[1];
        ipv4 = [ipv4 isEqualToString:@"0"]?@"":ipv4;
        ipv6 = [ipv6 isEqualToString:@"0"]?@"":ipv6;
        if (ipv4.length > 0 || ipv6.length > 0) {
            TTDNSIp *existIp = [self.ipParseCache objectForKey:domain];
            *refresh = YES; // 是否更新了
            if (existIp) {
                if ([ipv4 isEqualToString:existIp.ipv4] && [ipv6 isEqualToString:existIp.ipv6]) {
                    *refresh = NO;
                }else {
                    [existIp updateIpv4:ipv4 andIpv6:ipv6];
                }
            }else {
                existIp = [[TTDNSIp alloc] initWithIpv4:ipv4 ipv6:ipv6 domain:domain];
            }
            [self.ipParseCache setObject:existIp forKey:domain];
            return existIp;
        }
    }
    return nil;
}


- (void)reloadIpForDomain:(NSString *)domain {
    if ([self.domainReqTimes objectForKey:domain]) {
        return;;
    }
    [self.domainReqTimes setObject:@(CFAbsoluteTimeGetCurrent()) forKey:domain];
    [self getIpForDomain:domain async:^(TTDNSIp *ip) {
        [self.domainReqTimes removeObjectForKey:domain];
    }];
}


- (void)getIpForDomain:(NSString *)domain async:(void (^)(TTDNSIp * ip))handler {
    [[MSDKDns sharedInstance] WGGetHostByNameAsync:domain returnIps:^(NSArray *ipsArray) {
        [self log:@"TTNDS" message:@"domain:%@ getIpForDomain:%@",domain,ipsArray];
        BOOL refresh;
        TTDNSIp *ip = [self generateIpWithArray:ipsArray domain:domain isRefresh:&refresh];
        if (handler) {
            handler(ip);
        }
        if (refresh) {
            [self saveDns];
        }
    }];
}

/// 批量获取域名ip
- (void)getIpForDomains:(NSArray<NSString *> *)domains async:(void (^)(NSArray<TTDNSIp *> * ip))handler {
    [[MSDKDns sharedInstance] WGGetHostsByNamesAsync:domains returnIps:^(NSDictionary *ipsDictionary) {        
        [self log:@"TTNDS" message:@"domains :%@ getIpForDomains:%@", domains,ipsDictionary];
        NSMutableArray *array = [NSMutableArray array];
        BOOL needRefresh = NO;
        for (NSString*key in ipsDictionary.allKeys) {
            NSArray *ipsArray = ipsDictionary[key];
            BOOL refresh;
            TTDNSIp *ip = [self generateIpWithArray:ipsArray domain:key isRefresh:&refresh];
            if (!needRefresh) {
                needRefresh = refresh;
            }
            if (ip) {
                [array addObject:ip];
            }
        }
        handler?handler(array):nil;
        if (needRefresh) {
            [self saveDns];
        }
    }];
}





- (NSString *)urlStringWith:(NSString *)originString dnsIP:(TTDNSIp **)ipAddress {
    if (originString.length > 0) {
        NSURLComponents *url = [[NSURLComponents alloc] initWithString:originString];
        NSString *host = [url host];
        if (host && [self.whiteListsDic containsObject:host] && self.enable) {
            TTDNSIp *ip = [self ipByDomain:host];
            if (ip) {
                NSString *validIpHost = [ip validIpHost];
                if (validIpHost) {
                    NSRange rOriginal = [originString rangeOfString:host];
                    if (NSNotFound != rOriginal.location) { //替换第一个出现的地方
                        originString = [originString stringByReplacingCharactersInRange:rOriginal withString:validIpHost];
                        *ipAddress = ip;
                        return [originString stringByReplacingOccurrencesOfString:host withString:validIpHost];
                    }
                }
            }
        }
    }

    return originString;
}

- (NSString *)urlStringWith:(NSString *)originString {
    return [self urlStringWith:originString dnsIP:nil];
    
}

#pragma mark - 日志

- (void)log:(NSString * _Nullable )tag message:(NSString * _Nullable)format, ...NS_FORMAT_FUNCTION(2, 3) {
    va_list args;
    va_start(args, format);
    if (self.logdelegate && [self.logdelegate respondsToSelector:@selector(log:message:)]) {
        [self.logdelegate log:tag message:[NSString stringWithFormat:format,args]];
    }else {
        NSLog(@"[%@]:[%@]",tag,[NSString stringWithFormat:format,args]);
    }
    va_end(args);
}


#pragma mark - 默认的session代理 NSURLSessionDelegate


#pragma mark - 默认的nsurlconnection代理 NSURLSessionDelegate


@end
