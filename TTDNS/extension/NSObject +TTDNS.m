//
//  NSUrlSession+TTDNS.m
//  TTDNS
//
//  Created by 梁金锋 on 2022/1/10.
//

#import "NSObject+TTDNS.h"
#import <objc/message.h>
#import "TTDNS.h"
#import "NSURL+TTDNS.h"

@interface TTDNS()

- (BOOL)isClassHookedForSessionDns:(Class)cls;
- (void)setSessionHooked:(Class)cls;
- (BOOL)isClassHookedForConnDns:(Class)cls;
- (void)setConnHooked:(Class)cls;

@end

@implementation NSObject(TTDNS)

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * __nullable credential))completionHandler
{
    if (!challenge) {
        return;
    }
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    NSURLCredential *credential = nil;
    /*
     * 获取原始域名信息。
     */
    NSURLRequest *requst = task.currentRequest;
    NSString* host = [[requst allHTTPHeaderFields] objectForKey:@"host"];
    if (requst.URL.dnsIp) {
        host = requst.URL.dnsIp.domain;
    }
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if ([self evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:host]) {
            disposition = NSURLSessionAuthChallengeUseCredential;
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        } else {
            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        }
    } else {
        disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    }
    // 对于其他的challenges直接使用默认的验证方案
    completionHandler(disposition,credential);
}

- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust
                  forDomain:(NSString *)domain {
    /*
     * 创建证书校验策略
     */
    NSMutableArray *policies = [NSMutableArray array];
    if (domain) {
        [policies addObject:(__bridge_transfer id) SecPolicyCreateSSL(true, (__bridge CFStringRef) domain)];
    } else {
        [policies addObject:(__bridge_transfer id) SecPolicyCreateBasicX509()];
    }
    /*
     * 绑定校验策略到服务端的证书上
     */
    SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef) policies);
    /*
     * 评估当前serverTrust是否可信任，
     * 官方建议在result = kSecTrustResultUnspecified 或 kSecTrustResultProceed
     * 的情况下serverTrust可以被验证通过，https://developer.apple.com/library/ios/technotes/tn2232/_index.html
     * 关于SecTrustResultType的详细信息请参考SecTrust.h
     */
    SecTrustResultType result;
    SecTrustEvaluate(serverTrust, &result);
    return (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed);
}

#pragma mark - connectionDelegate

- (void)connection:(NSURLConnection *)connection
willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if (!challenge) {
        return;
    }
    /*
     * URL里面的host在使用HTTPDNS的情况下被设置成了IP，此处从HTTP Header中获取真实域名
     */
    NSURLRequest *requst = [connection currentRequest];
    NSString* host = [[requst allHTTPHeaderFields] objectForKey:@"host"];
    if (requst.URL.dnsIp) {
        host = requst.URL.dnsIp.domain;
    }
    /*
     * 判断challenge的身份验证方法是否是NSURLAuthenticationMethodServerTrust（HTTPS模式下会进行该身份验证流程），
     * 在没有配置身份验证方法的情况下进行默认的网络请求流程。
     */
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        if ([self evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:host]) {
            /*
             * 验证完以后，需要构造一个NSURLCredential发送给发起方
             */
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
        } else {
            /*
             * 验证失败，进入默认处理流程
             */
            [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
        }
    } else {
        /*
         * 对于其他验证方法直接进行处理流程
         */
        [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
    }
}


@end
