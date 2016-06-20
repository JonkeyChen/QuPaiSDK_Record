//
//  RecordVideoViewController.h
//  SaleHouseTest04
//
//  Created by 陈胜华 on 16/6/16.
//  Copyright © 2016年 oneyd.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QPSDK/QPSDK.h>

typedef void(^retureVideoBlock)(QPUploadTask *task);

@interface RecordVideoViewController : UIViewController

/**录制完成后回调*/
@property (nonatomic,copy) retureVideoBlock value;

@end
