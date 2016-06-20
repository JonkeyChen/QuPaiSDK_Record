//
//  PlayerVideoViewController.m
//  BaiChuanTest
//
//  Created by 陈胜华 on 16/6/20.
//  Copyright © 2016年 oneyd.me. All rights reserved.
//

#import "PlayerVideoViewController.h"

@interface PlayerVideoViewController (){

    UIWebView *_evWebView;
}

@end

@implementation PlayerVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self efConfigure];
}

- (void)efConfigure {

    _evWebView = ({
        UIWebView *webView = [[UIWebView alloc]init];
        webView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        [self.view addSubview:webView];
        webView;
    });
    
    NSURL *url = [NSURL URLWithString:self.playerUrl];
    
    [_evWebView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)dealloc {
    
    _evWebView = nil;
}

@end
