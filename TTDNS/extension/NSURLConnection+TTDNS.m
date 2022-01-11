//
//  NSURLConnection+TTDNS.m
//  TTDNS
//
//  Created by 梁金锋 on 2022/1/11.
//

#import "NSURLConnection+TTDNS.h"
#import <objc/message.h>
#import "NSObject+TTDNS.h"

@implementation NSURLConnection(TTDNS)
// 方法已经废弃 没有必要支持了
//+ (void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        Method fromMethod = class_getInstanceMethod(self, @selector(initWithRequest:delegate:));
//        Method toMethod = class_getInstanceMethod([self class],@selector(TTDNS_initWithRequest:delegate:));
//        method_exchangeImplementations(toMethod, fromMethod);
//    });
//}
//
//- (instancetype)TTDNS_initWithRequest:(NSURLRequest *)request delegate:(id)delegate {
//    NSURLConnection *conn = [self TTDNS_initWithRequest:request delegate:delegate];
//    return conn;
//}

@end
