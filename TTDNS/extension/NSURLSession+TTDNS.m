//
//  NSURLSession.m
//  TTDNS
//
//  Created by 梁金锋 on 2022/1/11.
//

#import "NSURL+TTDNS.h"
#import <objc/message.h>
#import "NSObject+TTDNS.h"
#import "TTDNS.h"

@implementation NSURLSession(TTNDS)

+ (NSURLSession *)ttSharedSession {
    NSURLSession *orgSession = [NSURLSession ttSharedSession];//系统自己的
    TTDNS *dns = [TTDNS shared];
    static dispatch_once_t onceToken;
    static NSURLSession * sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [NSURLSession sessionWithConfiguration:orgSession.configuration delegate:(id<NSURLSessionDelegate>)dns delegateQueue:orgSession.delegateQueue];
    });    
    return sharedInstance;
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method fromMethod = class_getInstanceMethod(self, @selector(delegate));
        Method toMethod = class_getInstanceMethod([self class],@selector(TTDNSDelegate));
        method_exchangeImplementations(toMethod, fromMethod);
        
        fromMethod = class_getClassMethod(self, @selector(ttSharedSession));
        toMethod = class_getClassMethod(self,@selector(sharedSession));
        method_exchangeImplementations(toMethod, fromMethod);
    });
}


- (id<NSURLSessionDelegate>)TTDNSDelegate {
    id<NSURLSessionDelegate> delegate = [self TTDNSDelegate];
    if (!delegate) {
        return (id<NSURLSessionDelegate>)[TTDNS shared];
    }
    return delegate;
}

@end
