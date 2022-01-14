# TTDNS
### 主要目的
在接入HTTPDNS的工程中，避免侵入到业务层的实现 （非SNI方案）。
支持 阿里云、腾讯云的解析、提供其他解析接入模版
引用后业务层不需要关心DNS解析的问题，采用白名单的方式，要将需要解析的域名提供。

### 主要功能
开启域名解析后能自动替换所有请求的URL.如 https://www.baidu.com 将自动被替换为 https://220.181.38.148。
避免了域名解析对业务的侵入，业务层不需要关心域名解析的事情。

### 主要接口
设置白名单
```
[[TTDNS shared] addWhiteListDomains:@[
        @"baidu.com",
]]
```

默认不可用，需要手动开启
```
[TTDNS shared].enable = YES;
```

获取域名缓存
```
[[TTDNS shared] ipByDomain:@"baidu.com"]

```

### 如何使用腾讯云接入
使用cocoapods导入
```
 pod "TTDNS"
 pod "TTDNS",:subspecs=>['TencentLoader']
```
如何使用
```
// 配置腾讯云帐号相关
DnsConfig config;
config.appId = @"xxxx";
config.dnsIp = @"1.1.1.1";
config.dnsId = 12345;
config.dnsKey = @"deskey";//des的密钥
config.encryptType = HttpDnsEncryptTypeDES;
config.debug = YES;
config.timeout = 5000;
// 设置解析器为腾讯云解析器
[[TTDNS shared] setDNSLoader:[[TTDNSTencentLoader alloc] init]];
[[TTDNS shared] addWhiteListDomains:@[
    @"baidu.com"
]];
[TTDNS shared].enable = YES;
```

### 如何使用阿里云接入
使用cocoapods导入
```
  pod "TTDNS",:subspecs=>["AliLoader"],:git => "git@github.com:simpossible/TTDNS.git",:branch=>"feature/feature_ali"
```
如何使用
```
//配置阿里云帐号
HttpDnsService *service = [[HttpDnsService alloc] initWithAccountID:1111 secretKey:@"qweqwqw"];
[service enableIPv6:YES];
[service setLogHandler:self];
// 指定阿里云的解析器
[[TTDNS shared] setDNSLoader:[[TTDNSAliLoader alloc] initWithService:service]];
```

### 如何接入其他解析方式

继承解析器，实现三种解析方式
```
@interface TTDNSLoader : NSObject

/// 不用实现
- (void)preLoadDNS:(NSArray<NSString *> *)hosts;

/// 同步的方式请求一个域名的解析
- (TTDNSIp *_Nullable)getIpByDomain:(NSString * _Nullable)domain;

/// 异步获取域名
- (void)getIpForDomain:(NSString * _Nullable)domain async:(void (^_Nullable)(TTDNSIp * _Nullable ip))handler;

/// 一步批量获取域名
- (void)getIpForDomains:(NSArray<NSString *> * _Nullable)domains async:(void (^_Nullable)(NSArray<TTDNSIp *> * _Nullable ips))handler;

@end
```


[部分思路说明](https://zhuanlan.zhihu.com/p/456131131)
