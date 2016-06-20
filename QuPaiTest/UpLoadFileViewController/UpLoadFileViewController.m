//
//  UpLoadFileViewController.m
//  QuPaiTest
//
//  Created by 陈胜华 on 16/6/17.
//  Copyright © 2016年 oneyd.me. All rights reserved.
//

#import "UpLoadFileViewController.h"
#import <QPSDK/QPSDK.h>
#import "Header.h"

@interface UpLoadFileViewController (){
    __weak IBOutlet UILabel *evlblRemoteId;
    __weak IBOutlet UILabel *evlblPrcent;
    
    __weak IBOutlet UIButton *evbtnReadVideo;
    __weak IBOutlet UIButton *evbtnPlayerVideo;
}

@end

@implementation UpLoadFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

//读取视频
- (IBAction)efOnClickReadVedioFile:(UIButton*)sender {
    
    [sender setTitle:@"正在读取.." forState:UIControlStateNormal];
    
    QPUploadTask * task = [[[QPUploadTaskManager shared] getAllUploadTasks] lastObject];
    
    if (!task) {
        
        [sender setTitle:@"暂无视频" forState:UIControlStateNormal];
        
        return;
    }
    
    [[QPUploadTaskManager shared] startUploadTask:task progress:^(CGFloat progress) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            sender.userInteractionEnabled = NO;
            
            evlblRemoteId.text = [NSString stringWithFormat:@"%f",progress];
        });
    } success:^(QPUploadTask *uploadTask, NSString *remoteId) {
        
        dispatch_async(dispatch_get_main_queue(), ^{

            sender.userInteractionEnabled = NO;
            
            [sender setTitle:@"上传成功" forState:UIControlStateNormal];
            
            evlblPrcent.text = @"upload success";
            
            evlblRemoteId.text = remoteId;
        });
    } failure:^(NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            sender.userInteractionEnabled = YES;
            
            [sender setTitle:@"重新读取" forState:UIControlStateNormal];
            
            evlblPrcent.text = @"upload failed";
        });
    }];
}

//上传视频
- (IBAction)efOnClickOpenVideo:(id)sender {

    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kStringAccessToken];
    
    NSString *videoString = [NSString stringWithFormat:@"http://%@/v/%@.mp4?token=%@", kQPDomain,evlblRemoteId.text, accessToken];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:videoString]];

}

@end
