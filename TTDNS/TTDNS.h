//
//  TTDNS.h
//  Pods-TTDNS
//
//  Created by ZERO-M1 on 2021/6/2.
//

#import <Foundation/Foundation.h>
#import "TTDNSLoader.h"
#import "TTDNSIp.h"
/**
 * 使用 NSURL 会自动将 urlstring 替换为ip解析后的结果
 *  使用 NSMutableURLRequest 如果触发了替换 那么会自动添加host字段
 */

@protocol TTDNSLogProtocol <NSObject>

@required
- (void)log:(NSString * _Nullable )tag message:(NSString * _Nullable)message;

@end

@interface TTDNS : NSObject

+ (instancetype __nonnull )shared;

@property (nonatomic, weak) id<TTDNSLogProtocol>_Nullable  logdelegate;

/// 是否可用
@property (nonatomic, assign) BOOL  enable;

@property (nonatomic, strong) NSArray<NSString *> * _Nullable whiteList;


/// 设置一个用来真正加载的loader
- (void)setDNSLoader:(TTDNSLoader * _Nonnull)loader;

/// 增加白名单的域名
- (void)addWhiteListDomain:(NSString *_Nullable)domain;

/// 批量增加白名单的域名
- (void)addWhiteListDomains:(NSArray<NSString *> *_Nullable)domains;

/// 全量刷新域名 
- (void)refreshWhiteListDomains:(NSArray<NSString *> * _Nullable)domains;

/// 域名是否在解析白名单内
- (BOOL)isDomainInWhiteList:(NSString *_Nullable)domain;

/// 设置缓存的根路径 避免开发中可能存在的切换环境的测试问题
- (void)setCacheRootDir:(NSString * _Nonnull)rootPath;


/// 从缓存获取一个域名的解析 如果获取不到进行刷_Nullable新
- (TTDNSIp *_Nullable)ipByDomain:(NSString *_Nullable)domain;

/// 同步的方式请求一个域名的解析
- (TTDNSIp *_Nullable)getIpByDomain:(NSString * _Nullable)domain;

/// 异步获取域名
- (void)getIpForDomain:(NSString * _Nullable)domain async:(void (^_Nullable)(TTDNSIp * _Nullable ip))handler;

/// 一步批量获取域名
- (void)getIpForDomains:(NSArray<NSString *> * _Nullable)domains async:(void (^_Nullable)(NSArray<TTDNSIp *> * _Nullable ips))handler;


/// 将会对白名单内的域名进行url替换
- (NSString * _Nullable)urlStringWith:(NSString * _Nullable)originString;

- (NSString * _Nullable)urlStringWith:(NSString * _Nullable)originString dnsIP:(TTDNSIp *_Nonnull*_Nullable)ipAddress;



@end

