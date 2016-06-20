//
// Created by huamulou on 15/5/31.
// Copyright (c) 2015 alibaba. All rights reserved.
//

#import <ALBBMediaService/ALBBMediaService.h>
#import <ALBBSDK/ALBBSDK.h>
#import "ALBBMedia.h"

#ifndef TFEDEBUG
#import <ALBBMediaService/ALBBMediaService.h>
#else
#import "ALBBMediaService.h"

#endif

#define TFE_SHARE_INSTANCE \
+(instancetype)sharedInstance \
{\
static dispatch_once_t once;\
static id instance;\
dispatch_once(&once, ^{instance = [self new];});\
return instance;\
}

@implementation ALBBMedia

//TFE_SHARE_INSTANCE

static id <ALBBMediaServiceProtocol> staticTaeFileEngine;

+ (instancetype) sharedInstance {
    
    static dispatch_once_t once;
    
    static id instance;
    
    dispatch_once(&once, ^{instance = [self new];});
    
    return instance;
}

- (id <ALBBMediaServiceProtocol>)taeFileEngine {
    if (!staticTaeFileEngine) {
        staticTaeFileEngine = [[ALBBSDK sharedInstance] getService:@protocol(ALBBMediaServiceProtocol)];
    }
    [staticTaeFileEngine setDebug:YES];
    return staticTaeFileEngine;
}

- (void)setTaeFileEngine:(id <ALBBMediaServiceProtocol>)service {
    staticTaeFileEngine = service;
}

- (NSString *)upload:(UpLoadType)type param:(id)param notification:(TFEUploadNotification *)notification {
    switch (type) {
        case UpLoadTypeFile:
            return [self uploadByFile:param  notification:notification];
        case UpLoadTypeData:
            return [self uploadByData:param  notification:notification];
        case UpLoadTypeAsset:
            return [self uploadByAsset:param notification:notification];
    }
    return nil;
}

- (NSString *)uploadByFile:(NSString *)filePath notification:(TFEUploadNotification *)notification {
    TFEUploadParameters *params = [TFEUploadParameters paramsWithFilePath:filePath
                                                                    space:nameSpace
                                                                 fileName:[[ALBBMedia sharedInstance] uniqueString]
                                                                      dir:dir];
    
    return [[[ALBBMedia sharedInstance] taeFileEngine] upload:params notification:notification];
}

- (NSString *)uploadByData:(NSData *)data notification:(TFEUploadNotification *)notification {
    TFEUploadParameters *params = [TFEUploadParameters paramsWithData:data
                                                                space:nameSpace
                                                             fileName:[[ALBBMedia sharedInstance] uniqueString]
                                                                  dir:dir];
    
    return [[[ALBBMedia sharedInstance] taeFileEngine] upload:params notification:notification];
}

- (NSString *)uploadByAsset:(NSURL *)assetUrl notification:(TFEUploadNotification *)notification {
    TFEUploadParameters *params = [TFEUploadParameters paramsWithAssertUrl:assetUrl
                                                                     space:nameSpace
                                                                  fileName:[[ALBBMedia sharedInstance] uniqueString]
                                                                       dir:dir];
    
    return [[[ALBBMedia sharedInstance] taeFileEngine] upload:params notification:notification];
}

/**
 * 生成一个uuid
 */
- (NSString *)uniqueString {
    
    CFUUIDRef uuidObj = CFUUIDCreate(nil);

    NSString *uuidString = (__bridge_transfer NSString *) CFUUIDCreateString(nil, uuidObj);
    
    CFRelease(uuidObj);
    
    return uuidString;
}


@end