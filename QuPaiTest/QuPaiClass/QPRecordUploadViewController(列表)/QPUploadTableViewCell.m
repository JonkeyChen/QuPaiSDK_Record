//
//  QPUploadTableViewCell.m
//  QupaiSDKDevApp
//
//  Created by zhangwx on 16/1/8.
//  Copyright © 2016年 lyle. All rights reserved.
//

#import "QPUploadTableViewCell.h"

@interface QPUploadTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *filePathLabel;
@property (weak, nonatomic) IBOutlet UILabel *cidLabel;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@implementation QPUploadTableViewCell

-(void)setUploadTask:(QPUploadTask *)uploadTask{
    
    _uploadTask = uploadTask;
    
    self.filePathLabel.text = uploadTask.taskId;
    
    self.cidLabel.text = uploadTask.uploadId;
    
    if (uploadTask.uploadFinished) {
        
        [self.actionButton setTitle:@"打开视频" forState:UIControlStateNormal];
    }else{
        
        [self.actionButton setTitle:@"上传" forState:UIControlStateNormal];
    }
    self.statusLabel.text = [NSString stringWithFormat:@"%f",uploadTask.progress];
}

- (IBAction)uploadButtonClicked:(id)sender {

    if ([self.delegate respondsToSelector:@selector(qPUploadTableViewCell:withUpLoadTask:)]) {
        
        [self.delegate qPUploadTableViewCell:self withUpLoadTask:_uploadTask];
    }
}

- (void)awakeFromNib {
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
