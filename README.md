# TTDNS
### 主要目的
引用后业务层不需要关心DNS解析的问题，采用白名单的方式，要将需要解析的域名提供。

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
[部分思路说明](https://zhuanlan.zhihu.com/p/456131131)
