
//
//  UpLoadCell.m
//  BaiChuanTest
//
//  Created by 陈胜华 on 16/6/20.
//  Copyright © 2016年 oneyd.me. All rights reserved.
//

#import "UpLoadCell.h"
#import "NSURL+Extend.h"

@interface UpLoadCell ()

@property(nonatomic, weak  ) UpLoadEntity *datasrc;

@end

@implementation UpLoadCell

- (void)awakeFromNib {

    [super awakeFromNib];
    
    _evimgeHeader.layer.masksToBounds = YES;
    
    _evimgeHeader.layer.cornerRadius = 5;
}

//配置显示数据
- (void)setData:(UpLoadEntity*)data {
    
    @synchronized (self) {
        
        self.evimgeHeader.image = data.image;
        
        self.evlblUpLoadInfo.text = [NSString stringWithFormat:@"%@",@(data.sizeUploaded)];
        
        self.evlblImageSize.text = [NSString stringWithFormat:@"%.3f KB",data.size/1024.0/1024];
        
        self.evlblImageName.text = data.filename;
        
        unsigned long su = data.sizeUploaded;
        
        int progress = (int)data.progress;
        
        int status = data.status;
        
        _evbtnApiPicture.userInteractionEnabled = YES;
        
        switch (status) {
            case 0:
                self.evlblStatus.text = @"未开始";
                break;
            case 1:{
                progress = 100;
                
                self.evlblStatus.text = @"成功";
                
                _evbtnApiPicture.userInteractionEnabled = NO;
            }
                break;
            case 2:{
                progress = 100;
                self.evlblStatus.text = @"失败";
            }
                break;
            case 3:
                self.evlblStatus.text = @"上传中";
                break;
            case 4:
                self.evlblStatus.text = @"取消";
                break;
                
            default:
                break;
        }
        
        float screenWidth = [UIScreen mainScreen].bounds.size.width ;
        
        if (su > 0) {
            
            float length = screenWidth - [UIScreen mainScreen].bounds.size.width * progress / 100;
            
            self.evProgressToRightProgress.constant = length;
        } else {
            
            self.evProgressToRightProgress.constant = screenWidth;
        }
        
        
        if (status == 1) {
            
            self.evbtnCancleUpLoad.hidden = NO;
        } else {
            
            self.evbtnCancleUpLoad.hidden = YES;
        }
        
        self.evlblUpLoadInfo.text = data.url;
        
        _datasrc = data;
    }
}

/**
 * 对cell重新初始化
 */
- (void)reInit {

    _datasrc.dTime        = 0;
    _datasrc.timeUsed     = 0;
    _datasrc.url          = @"";
    _datasrc.status       = 0;
    _datasrc.sizeUploaded = 0;
    _datasrc.timeStart    = [[NSDate new] timeIntervalSince1970];
    
    self.evlblImageName.text = @"";
    self.evlblStatus.text = @"未开始";
    self.evProgressToRightProgress.constant = [UIScreen mainScreen].bounds.size.width;
}

//上传图片／视频
- (IBAction)efOnClickPictureLoad:(id)sender {
    
    if (_datasrc.status == 3) {
        return;
    }
    
    [self reInit];
    
    TFEUploadNotification *notification = [TFEUploadNotification notificationWithProgress:^(TFEUploadSession *session, NSUInteger progress) {
        
        _datasrc.status   = LoadStatusUploading;

        _datasrc.progress = progress;
        
        _datasrc.sizeUploaded = session.sizeUploaded;
        
        [self responseDelegate:_datasrc withStatus:LoadStatusUploading];
        
    } success:^(TFEUploadSession *session, NSString *url) {
        
        _datasrc.status = LoadStatusSuccess;
        
        _datasrc.url = session.responseUrl;
        
        _datasrc.timeUsed = ([[NSDate new] timeIntervalSince1970] - session.startTime) * 1000;
        
        [self responseDelegate:_datasrc withStatus:LoadStatusSuccess];
    } failed:^(TFEUploadSession *session, NSError *error) {
        
        _datasrc.status = session.isCanceled ? 4 : 2;
        
        _datasrc.timeUsed = ([[NSDate new] timeIntervalSince1970] - session.startTime) * 1000;
        
        [self responseDelegate:_datasrc withStatus:LoadStatusFailed];
    }];
    
    NSString *ID = [[ALBBMedia sharedInstance] upload:UpLoadTypeAsset
                                                param:[NSURL URLWithString:_datasrc.assetsUrl]//[_datasrc objectForKey:@"assetsUrl"]
                                         notification:notification];
    if (ID){
        
        _datasrc.taskId = ID;
    }
}

- (void)responseDelegate:(UpLoadEntity*)data withStatus:(LoadStatus)loadStatus{
    
    if ([_delegate respondsToSelector:@selector(upLoadCell:withData:withLoadStatus:)]) {
        
        [_delegate upLoadCell:self withData:data withLoadStatus:loadStatus];
    }
}

/**播放按钮*/
- (IBAction)efOnClickCancleLoad:(id)sender {
    
    if ([_delegate respondsToSelector:@selector(upLoadCell:withIndexPath:withData:)]) {
        
        [_delegate upLoadCell:self withIndexPath:_row withData:_datasrc];
    }
}

/*

- (void)upLoadWithType:(UpLoadType)type {
    switch (type) {
        case UpLoadTypeAsset: {
            
            if ([[_datasrc objectForKey:@"status"] intValue] == 3)
                return;
            
            [self reInit];
            
            TFEUploadNotification *notification = [TFEUploadNotification notificationWithProgress:^(TFEUploadSession *session, NSUInteger progress) {
                NSLog(@"%lu", (unsigned long) progress);
                
                [_datasrc setObject:[NSNumber numberWithInt:LoadStatusUploading] forKey:@"status"];
                [_datasrc setObject:[NSNumber numberWithUnsignedLong:progress] forKey:@"progress"];
                [_datasrc setObject:[NSNumber numberWithUnsignedLong:session.sizeUploaded] forKey:@"sizeUploaded"];
                
                [self responseDelegate:_datasrc withStatus:LoadStatusUploading];
            } success:^(TFEUploadSession *session, NSString *url) {
                
                [_datasrc setObject:[NSNumber numberWithInt:LoadStatusSuccess] forKey:@"status"];
                [_datasrc setObject:session.responseUrl forKey:@"url"];
                [_datasrc setObject:[NSNumber numberWithDouble:([[NSDate new] timeIntervalSince1970] - session.startTime) * 1000] forKey:@"timeUsed"];
                
                [self responseDelegate:_datasrc withStatus:LoadStatusSuccess];
            } failed:^(TFEUploadSession *session, NSError *error) {
                
                [_datasrc setObject:session.isCanceled ? @4 : @2 forKey:@"status"];
                [_datasrc setObject:[NSNumber numberWithDouble:([[NSDate new] timeIntervalSince1970] - session.startTime) * 1000] forKey:@"timeUsed"];
                
                [self responseDelegate:_datasrc withStatus:LoadStatusFailed];
            }];
            
            NSString *ID = [[ALBBMedia sharedInstance] upload:type
                                                        param:[NSURL URLWithString:[_datasrc objectForKey:@"assetsUrl"]]
                                                 notification:notification];
            if (ID){
                [_datasrc setObject:ID forKey:@"taskId"];
            }
        }
            break;
            
        case UpLoadTypeData: {
 
              通过data方式上传
              1. 把图库文件读取成nsdata(为了方便，把图库读取成data，真实app无需先保存到图库再读取data）
              2. 通过data方式上传
 
            if ([[_datasrc objectForKey:@"status"] intValue] == 3){
                return;
            }
            
            NSArray *cacPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            
            NSString *cachePath = [cacPath objectAtIndex:0];
            
            NSLog(@"%@", cacPath);
            
            NSString *filePath = [cachePath stringByAppendingPathComponent:[[ALBBMedia sharedInstance] uniqueString]];
            
            [self reInit];
            
            [[NSURL URLWithString:[_datasrc objectForKey:@"assetsUrl"]] assetToFile:filePath];
            
            TFEUploadNotification *notification = [TFEUploadNotification notificationWithProgress:^(TFEUploadSession *session, NSUInteger progress) {
                NSLog(@"%lu", (unsigned long) progress);
                
                [_datasrc setObject:[NSNumber numberWithInt:LoadStatusUploading] forKey:@"status"];
                [_datasrc setObject:[NSNumber numberWithUnsignedLong:progress] forKey:@"progress"];
                [_datasrc setObject:[NSNumber numberWithUnsignedLong:session.sizeUploaded] forKey:@"sizeUploaded"];
                
                [self responseDelegate:_datasrc withStatus:LoadStatusUploading];
            } success:^(TFEUploadSession *session, NSString *url) {
                [_datasrc setObject:[NSNumber numberWithDouble:([[NSDate new] timeIntervalSince1970] - session.startTime) * 1000] forKey:@"timeUsed"];
                
                [_datasrc setObject:[NSNumber numberWithInt:LoadStatusSuccess] forKey:@"status"];
                [_datasrc setObject:session.responseUrl forKey:@"url"];
                
                [self responseDelegate:_data withStatus:LoadStatusSuccess];
            } failed:^(TFEUploadSession *session, NSError *error) {
                if (session.isCanceled) {
                    [_datasrc setObject:[NSNumber numberWithInt:LoadStatusCancel] forKey:@"status"];
                } else {
                    [_datasrc setObject:[NSNumber numberWithInt:LoadStatusFailed] forKey:@"status"];
                    
                }

                [self responseDelegate:_datasrc withStatus:LoadStatusFailed];
                
                [_datasrc setObject:[NSNumber numberWithDouble:([[NSDate new] timeIntervalSince1970] - session.startTime) * 1000] forKey:@"timeUsed"];
            }];
            
            NSString *ID = [[ALBBMedia sharedInstance] upload:type
                                                        param:filePath
                                                 notification:notification];
            if (ID) {
                [_datasrc setObject:ID forKey:@"taskId"];
            }
            
        }
            break;
        case UpLoadTypeFile: {
 
              通过文件方式上传
              1. 把图库文件保存成本地文件。(为了方便，图库文件保存成本地文件，真实app无需先保存到图片再转换文件上传）
              2. 通过文件方式上传
 
            
            if ([[_datasrc objectForKey:@"status"] intValue] == 3) {
                return;
            }
            
            NSArray *cacPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            
            NSString *cachePath = [cacPath objectAtIndex:0];
            
            NSLog(@"%@", cacPath);
            
            NSString *filePath = [cachePath stringByAppendingPathComponent:[[ALBBMedia sharedInstance] uniqueString]];

            [self reInit];
            
            [[NSURL URLWithString:[_datasrc objectForKey:@"assetsUrl"]] assetToFile:filePath];
            
            TFEUploadNotification *notification = [TFEUploadNotification notificationWithProgress:^(TFEUploadSession *session, NSUInteger progress) {
                NSLog(@"%lu", (unsigned long) progress);
                
                [_datasrc setObject:[NSNumber numberWithInt:LoadStatusUploading] forKey:@"status"];
                [_datasrc setObject:[NSNumber numberWithUnsignedLong:progress] forKey:@"progress"];
                [_datasrc setObject:[NSNumber numberWithUnsignedLong:session.sizeUploaded] forKey:@"sizeUploaded"];
                
                [self responseDelegate:_datasrc withStatus:LoadStatusUploading];
            } success:^(TFEUploadSession *session, NSString *url) {
                [_datasrc setObject:[NSNumber numberWithDouble:([[NSDate new] timeIntervalSince1970] - session.startTime) * 1000] forKey:@"timeUsed"];
                
                [_datasrc setObject:[NSNumber numberWithInt:LoadStatusSuccess] forKey:@"status"];
                [_datasrc setObject:session.responseUrl forKey:@"url"];
                
                [self responseDelegate:_datasrc withStatus:LoadStatusSuccess];
            } failed:^(TFEUploadSession *session, NSError *error) {
                if (session.isCanceled) {
                    [_datasrc setObject:[NSNumber numberWithInt:LoadStatusCancel] forKey:@"status"];
                } else {
                    [_datasrc setObject:[NSNumber numberWithInt:LoadStatusFailed] forKey:@"status"];
                }
                
                [self responseDelegate:_datasrc withStatus:LoadStatusFailed];
                
                [_datasrc setObject:[NSNumber numberWithDouble:([[NSDate new] timeIntervalSince1970] - session.startTime) * 1000] forKey:@"timeUsed"];
            }];

            NSString *ID = [[ALBBMedia sharedInstance] upload:type
                                                        param:filePath
                                                 notification:notification];
            if (ID) {
                [_datasrc setObject:ID forKey:@"taskId"];
            }
            
        }
            break;
            
        default:
            break;
    }
}
 */

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
