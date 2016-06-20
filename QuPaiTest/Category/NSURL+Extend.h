//
// Created by huamulou on 15-2-15.
// Copyright (c) 2015 alibaba. All rights reserved.



#import  <Foundation/Foundation.h>

@interface NSURL (Extend)

- (NSData *)readAssetByError:(NSError **)error;

- (NSData *)readAssetFrom:(unsigned long)from size:(unsigned long)blockSize error:(NSError **)error;

- (NSDictionary *)needData:(BOOL)needData needSize:(BOOL)needSize needMd5:(BOOL)needMd5 needSuffix:(BOOL)needSuffix needDimensionOfAsset:(BOOL)needDimension;


- (void)assetToFile:(NSString *)filePath;
@end