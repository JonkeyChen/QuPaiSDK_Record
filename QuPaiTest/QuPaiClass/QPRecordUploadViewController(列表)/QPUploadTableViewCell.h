//
//  QPUploadTableViewCell.h
//  QupaiSDKDevApp
//
//  Created by zhangwx on 16/1/8.
//  Copyright © 2016年 lyle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QPSDK/QPSDK.h>

@class QPUploadTableViewCell;

@protocol QPUploadTableViewCellDelegate <NSObject>

- (void)qPUploadTableViewCell:(QPUploadTableViewCell *)cell withUpLoadTask:(QPUploadTask*)uploadTask;

@end

@interface QPUploadTableViewCell : UITableViewCell

@property (strong, nonatomic) QPUploadTask *uploadTask;

@property (weak, nonatomic) id<QPUploadTableViewCellDelegate> delegate;
@end
