//
//  ViewController.m
//  QuPaiTest
//
//  Created by 陈胜华 on 16/6/17.
//  Copyright © 2016年 oneyd.me. All rights reserved.
//

#import "ViewController.h"
#import "Header.h"
#import "RecordVideoViewController.h"
#import "QPRecordUploadViewController.h"
#import "UpLoadViewController.h"

@interface ViewController ()

@end

static NSString *const quPaiKey       = @"208d7cfb8dd003c";                 //趣拍key
static NSString *const quPaiSecret    = @"8adb6c310ff74bdd94ece4da593907a6";//趣拍Secret

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBar.translucent = NO;
    
    [self efCheckRegister];
    
    [[ALBBSDK sharedInstance] setDebugLogOpen:NO];//开发阶段打开日志开关，方便排查错误信息
    
    //授权注册阿里百川
    [[ALBBSDK sharedInstance] asyncInit:^{
        
        NSLog(@"注册授权成功(阿里百川)");
    } failure:^(NSError *error) {
        
        NSLog(@"注册授权失败(阿里百川 %@)",error);
    }];
}


- (IBAction)efOnClcikRecordVideo:(id)sender {
    
    NSLog(@"去拍摄");
    
    RecordVideoViewController *recordVideoVC = [[RecordVideoViewController alloc]init];
    
    [self.navigationController pushViewController:recordVideoVC animated:YES];
}

- (IBAction)efOnClcikUpLoadVedio:(id)sender {
    
    NSLog(@"读取");
    
    UpLoadViewController *upLoadVC = [[UpLoadViewController alloc]init];
    
    [self.navigationController pushViewController:upLoadVC animated:YES];
}

- (IBAction)efOnClcikRecordsList:(id)sender {
    
    NSLog(@"视频列表");
    
    QPRecordUploadViewController *recordListVC = [[QPRecordUploadViewController alloc]init];
    
    [self.navigationController pushViewController:recordListVC animated:YES];
}

/**检查是否注册*/
- (void)efCheckRegister{
    
    [[QPAuth shared] registerAppWithKey:quPaiKey secret:quPaiSecret space:@"newFiles" success:^(NSString *accessToken) {
        
        NSLog(@"access token : %@", accessToken);
        
        [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:kStringAccessToken];
    } failure:^(NSError *error) {
        
        NSLog(@"failed : %@", error.description);
    }];
}

@end
