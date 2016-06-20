//
//  QPUploadViewController.m
//  QupaiSDKDevApp
//
//  Created by zhangwx on 16/1/8.
//  Copyright © 2016年 lyle. All rights reserved.
//

#import "QPRecordUploadViewController.h"
#import <QPSDK/QPSDK.h>
#import "Header.h"
#import "RecordVideoViewController.h"

static NSString * const QPUploadTableViewCellID = @"QPUploadTableViewCellID";

@interface QPRecordUploadViewController (){
    
    NSMutableArray<QPUploadTask*> *_recordsVideoArray;
}

@property (weak, nonatomic) IBOutlet UITextField *minDurationTextField;
@property (weak, nonatomic) IBOutlet UITextField *maxDurationTextField;
@property (weak, nonatomic) IBOutlet UITextField *bitRateTextField;
@property (weak, nonatomic) IBOutlet UITextField *widthTextField;
@property (weak, nonatomic) IBOutlet UITextField *heightTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation QPRecordUploadViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self efConfigure];
}

//初始化属性
- (void)efConfigure{
    
    _recordsVideoArray = [NSMutableArray array];
    
    [_recordsVideoArray addObjectsFromArray:[[QPUploadTaskManager shared] getAllUploadTasks]];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"QPUploadTableViewCell" bundle:nil]
         forCellReuseIdentifier:QPUploadTableViewCellID];
    
    self.tableView.rowHeight = 120.0;
}

#pragma mark - Action
//录制视频
- (IBAction)efOnClickStartRecordVideo:(id)sender {
    
    RecordVideoViewController *recordVideoVC = [[RecordVideoViewController alloc]init];
    
    recordVideoVC.value = ^(QPUploadTask *task) {
        
        [_recordsVideoArray addObject:task];
        
        [_tableView reloadData];
    };
    
    [self.navigationController pushViewController:recordVideoVC animated:YES];
}

//删除所有任务
- (IBAction)efOnClickDeleteAllRecords:(id)sender {
    
    [_recordsVideoArray removeAllObjects];
    
    [[QPUploadTaskManager shared] removeAllUploadTasks];
    
    [self.tableView reloadData];
    
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSString *testDirPath = [documentPath stringByAppendingPathComponent:kStringTempFiles];
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    [fileMgr removeItemAtPath:testDirPath error:nil];
}

- (IBAction)tapGesture:(id)sender {
    [self.view endEditing:YES];
}

#pragma mark - TableView DataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _recordsVideoArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QPUploadTableViewCell *uploadCell = [tableView dequeueReusableCellWithIdentifier:QPUploadTableViewCellID];
    
    uploadCell.uploadTask = _recordsVideoArray[indexPath.row];
    
    uploadCell.delegate = self;
    
    return uploadCell;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return YES;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    QPUploadTask *task = _recordsVideoArray[indexPath.row];
    
    [[QPUploadTaskManager shared] removeUploadTask:task];
    
    [_recordsVideoArray removeObject:task];
    
    [self.tableView reloadData];
}
#pragma mark - QPUploadTableViewCell Delegate
-(void)qPUploadTableViewCell:(QPUploadTableViewCell *)cell withUpLoadTask:(QPUploadTask *)uploadTask{
    
    if (uploadTask.uploadFinished) {
        
        NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:kStringAccessToken];
        
        NSString *videoString = [NSString stringWithFormat:@"http://%@/v/%@.mp4?token=%@", kQPDomain, uploadTask.remoteId, accessToken];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:videoString]];
    }else {
        
        [[QPUploadTaskManager shared] startUploadTask:uploadTask progress:^(CGFloat progress) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [_tableView reloadData];
            });
        } success:^(QPUploadTask *uploadTask, NSString *remoteId) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [_tableView reloadData];
            });
        } failure:^(NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [_tableView reloadData];
            });
        }];
    }
}

@end
