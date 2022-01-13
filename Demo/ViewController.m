//
//  ViewController.m
//  Demo
//
//  Created by ZERO-M1 on 2021/10/13.
//

#import "ViewController.h"
#import <TTDNS/TTDNS.h>
#import <MSDKDns_C11/MSDKDns.h>
#import <AlicloudHttpDNS/AlicloudHttpDNS.h>
@import TTDNS;
@import Masonry;
//#import <BeaconAPI_Base/BeaconBaseInterface.h>


@interface ViewController ()<HttpdnsLoggerProtocol>

@property (nonatomic, strong) UIButton * requestButton;

@property (nonatomic, strong) UITextView * stringlabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initialUI];
    [self initalAliConfig];
}

- (void)initialUI {
    
    
    self.requestButton = [[UIButton alloc] init];
    [self.view addSubview:self.requestButton];
    [self.requestButton setTitle:@"点击请求" forState:(UIControlStateNormal)];
    [self.requestButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(100);
        make.height.mas_equalTo(48);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(200);
    }];
    self.requestButton.backgroundColor = [UIColor orangeColor];
    self.requestButton.layer.cornerRadius = 12;
    self.requestButton.layer.masksToBounds = YES;
    [self.requestButton addTarget:self action:@selector(testRequest) forControlEvents:(UIControlEventTouchUpInside)];
    
    self.stringlabel = [[UITextView alloc] init];
    [self.view addSubview:self.stringlabel];
    
    [self.stringlabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
        make.top.equalTo(self.requestButton.mas_bottom).offset(16);
    }];
    
    
}


- (void)initialTencentConfig {
    /// 这里是腾讯云的配置
    DnsConfig config ;
    [self configTestLab:&config];
    [[MSDKDns sharedInstance] initConfig: &config];
        
    [[TTDNS shared] setDNSLoader:[[TTDNSTencentLoader alloc] init]];
    [[TTDNS shared] addWhiteListDomains:@[
        @"baidu.com",
    ]];
    
    [TTDNS shared].enable = YES;
}

- (void)initalAliConfig {
    
    /// 这里是腾讯云的配置
    DnsConfig config ;
    [self configTestLab:&config];
    [[MSDKDns sharedInstance] initConfig: &config];
    

    HttpDnsService *service = [[HttpDnsService alloc] initWithAccountID:1111 secretKey:@"qweqwqw"];
    [service enableIPv6:YES];
    [service setLogHandler:self];
        
    [[TTDNS shared] setDNSLoader:[[TTDNSAliLoader alloc] initWithService:service]];
    [[TTDNS shared] addWhiteListDomains:@[
        @"baidu.com",
    ]];
    
    [TTDNS shared].enable = YES;
}

/// 配置正式环境
- (void)configTestLab:(DnsConfig *)config {
    (*config).appId = @"xxxx";
    (*config).dnsIp = @"1.1.1.1";
    (*config).dnsId = 12345;
    (*config).dnsKey = @"deskey";//des的密钥
    (*config).encryptType = HttpDnsEncryptTypeDES;
//    (*config).debug = YES;
    (*config).timeout = 5000;
}


- (void)testRequest {
    NSURL *url = [NSURL URLWithString:@"https://www.baidu.com"];
    NSLog(@"域名解析结果是:%@",url.absoluteString);
    [self log:[NSString stringWithFormat:@"域名解析结果是:%@",url.absoluteString]];
    [[NSURLSession sharedSession] downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            [self log:[NSString stringWithFormat:@"请求结果:%@",error]];
        }else {
            [self log:@"请求成功"];;
        }
    }];
}

- (void)log :(NSString *)text {
    if ([[NSThread currentThread] isMainThread]) {
        NSString *string = [NSString stringWithFormat:@"%@ \n %@",text,self.stringlabel.text?:@""];
        self.stringlabel.text = string;
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *string = [NSString stringWithFormat:@"%@ \n %@",text,self.stringlabel.text?:@""];
            self.stringlabel.text = string;
        });
    }
}


@end
