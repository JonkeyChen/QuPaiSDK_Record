//
//  ALAssetRepresentation+extend.h
//
//  Created by huamulou on 14-11-14.
//  Copyright (c) 2014年 showmethemoney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAssetRepresentation (extend)

- (NSString *)md5;

- (NSData *)toNSData;

- (void)toFile:(NSString *)filePath;
@end
