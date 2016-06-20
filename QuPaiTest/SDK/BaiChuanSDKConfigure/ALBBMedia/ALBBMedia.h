//
// Created by huamulou on 15/5/31.
// Copyright (c) 2015 alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ALBBMediaService/ALBBMediaService.h>

//#define DEMO_ALBBM   [ALBBMedia sharedInstance]j
//#define DEMO_ENGINE [[ALBBMedia sharedInstance] taeFileEngine]
//#define DEMO_UUID   [[ALBBMedia sharedInstance] uniqueString]
//#define DEMO_NAMESPACE @"jonkeychenbaichuan"                  //请及时替换成你自己的安全图片和namespace，测试地址会定时清理文件的
//#define DEMO_DIR @"/PictureFiles" //@"/PENGUY/tempUpload"
//#define DEMO_TYPE_FILE 1
//#define DEMO_TYPE_DATA 2
//#define DEMO_TYPE_ASSET 3

//#define demoUpload(_type, _param, _notification) \
//[DEMO_ALBBM upload:_type param:_param notification:_notification];

static NSString *const nameSpace = @"jonkeychenbaichuan";
static NSString *const dir       = @"/PictureFiles";

/**上传Type*/
typedef NS_ENUM(NSUInteger, UpLoadType){
    /**上传文件*/
    UpLoadTypeFile,
    /**上传NSData数据*/
    UpLoadTypeData,
    /**上传Asset数据*/
    UpLoadTypeAsset,
};

@class TFEUploadNotification;
@protocol ALBBMediaServiceProtocol;

@interface ALBBMedia : NSObject

+ (instancetype)sharedInstance;

/**
* taefileengine的实例
*/
@property(nonatomic, strong) id <ALBBMediaServiceProtocol> taeFileEngine;


- (NSString *)upload:(UpLoadType)type param:(id)param notification:(TFEUploadNotification *)notification;

/**
* @brief 使用本地文件地址上传
*/
- (NSString *)uploadByFile:(NSString *)filePath notification:(TFEUploadNotification *)notification;

/**
* @brief 使用data方式上传
*/
- (NSString *)uploadByData:(NSData *)data notification:(TFEUploadNotification *)notification;


/**
* @brief 使用图库链接上传
*/
- (NSString *)uploadByAsset:(NSURL *)assetUrl notification:(TFEUploadNotification *)notification;

- (NSString *)uniqueString;

@end