//
//  AFURLSessionManager+TTDNS.m
//  TTDNS
//
//  Created by 梁金锋 on 2022/1/11.
//

#import "AFURLSessionManager+TTDNS.h"
#import <objc/message.h>
#import "NSURL+TTDNS.h"
#import "NSObject+TTDNS.h"
@import AFNetworking;

@implementation AFURLSessionManager(TTDNS)

-(instancetype)TTDNS_initWithSessionConfiguration:(NSURLSessionConfiguration *)configuration {
    AFURLSessionManager *manager = [self TTDNS_initWithSessionConfiguration:configuration];
    [manager setAuthenticationChallengeHandler:^id _Nonnull(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, NSURLAuthenticationChallenge * _Nonnull challenge, void (^ _Nonnull completionHandler)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable)) {
        if (!challenge) {
            return nil;
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
        return credential;
    }];
    return manager;
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method fromMethod = class_getInstanceMethod(self, @selector(initWithSessionConfiguration:));
        Method toMethod = class_getInstanceMethod([self class],@selector(TTDNS_initWithSessionConfiguration:));
        method_exchangeImplementations(toMethod, fromMethod);
    });
}



@end
