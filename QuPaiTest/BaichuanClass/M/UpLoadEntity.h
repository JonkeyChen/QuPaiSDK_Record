//
//  UpLoadEntity.h
//  QuPaiTest
//
//  Created by 陈胜华 on 16/6/21.
//  Copyright © 2016年 oneyd.me. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**(图片/视频)资源数据模型*/
@interface UpLoadEntity : NSObject

/**从系统获取的资源转化成的图片对象*/
@property (nonatomic, strong) UIImage   *image ;
/**上传晚上后，生产的url地址*/
@property (nonatomic, copy  ) NSString  *url ;
/**从系统获取的资源url path*/
@property (nonatomic, copy  ) NSString  *assetsUrl ;
/**文件名字*/
@property (nonatomic, copy  ) NSString  *filename ;
/**uuidString 标识*/
@property (nonatomic, copy  ) NSString  *name ;
/**上传任务ID*/
@property (nonatomic, copy  ) NSString  *taskId;
/**资源大小byte*/
@property (nonatomic, assign) NSInteger  size ;
/**设置资源表示（UpLoadEntity对象是否为首次初始化）*/
@property (nonatomic, assign) NSInteger  type  ;
/**上传byte大小*/
@property (nonatomic, assign) NSInteger  uploadedSize ;
/**上传进度(0~100)*/
@property (nonatomic, assign) NSInteger  progress;
/**上传消耗时间*/
@property (nonatomic, assign) NSInteger  dTime;
/**上传的状态0,1（成功）,2,3,4*/
@property (nonatomic, assign) int        status ;
@property (nonatomic, assign) double     sizeUploaded;
@property (nonatomic, assign) double     timeStart;
@property (nonatomic, assign) double     timeUsed;

@end
