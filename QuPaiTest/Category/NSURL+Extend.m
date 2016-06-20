//
// Created by huamulou on 15-2-15.
// Copyright (c) 2015 alibaba. All rights reserved.


#import "NSURL+Extend.h"
#import "ALAssetRepresentation+Extend.h"


@implementation NSURL (Extend)


- (NSData *)readAssetByError:(NSError **)error {
    NSDictionary *dic = [self needData:YES needSize:NO needMd5:NO needSuffix:NO needDimensionOfAsset:NO];

    NSError *readError = [dic objectForKey:@"error"];
    if (readError && error) {
        *error = readError;
        return nil;
    }
    return [dic objectForKey:@"data"];

}

- (NSData *)readAssetFrom:(unsigned long)from size:(unsigned long)blockSize error:(NSError **)error {
    //创建一个信号量，等待图库读取完我们才
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    __block NSData *result;
    __block NSError *blockError = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset) {
            @try {
                ALAssetRepresentation *rep = [myasset defaultRepresentation];
                if (!rep) {
                    blockError = [NSError errorWithDomain:@"test" code:0 userInfo:@{@"message" : @"图库文件无法读取"}];
                    return;
                }
                NSData *uploadData = nil;
                uint8_t *buffer;
                NSUInteger bytesRead = 0;
                NSError *repReadError;
                buffer = calloc(blockSize, sizeof(*buffer));
                bytesRead = [rep getBytes:buffer fromOffset:(long long) from length:blockSize error:&repReadError];
                uploadData = [NSData dataWithBytesNoCopy:buffer length:bytesRead freeWhenDone:YES];
                if (!uploadData) {
                    blockError = [NSError errorWithDomain:@"test" code:0 userInfo:@{@"message" : @"图库文件无法读取"}];
                    return;
                }
                if (repReadError) {
                    blockError = [NSError errorWithDomain:@"test" code:0 userInfo:@{@"message" : @"图库文件无法读取"}];
                    return;
                }

                result = uploadData;
            }
            @finally {
                dispatch_semaphore_signal(semaphore);
            }
        };

        //
        ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *myerror) {
            blockError = [NSError errorWithDomain:@"test" code:0 userInfo:@{@"message" : @"图库文件无法读取"}];
        };


        ALAssetsLibrary *assetslibrary = [[ALAssetsLibrary alloc] init];
        [assetslibrary assetForURL:self
                       resultBlock:resultblock
                      failureBlock:failureblock];
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    if (blockError && error) {
        *error = blockError;
    }
    return result;

}


- (NSDictionary *)needData:(BOOL)needData needSize:(BOOL)needSize needMd5:(BOOL)needMd5 needSuffix:(BOOL)needSuffix needDimensionOfAsset:(BOOL)needDimension {
    //创建一个信号量，等待图库读取完我们才
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    NSMutableDictionary *dic = [NSMutableDictionary new];

    __block NSError *blockError = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset) {
            @try {
                ALAssetRepresentation *rep = [myasset defaultRepresentation];
                if (rep) {
                    if (needSize) {
                        [dic setObject:[NSNumber numberWithLongLong:rep.size] forKey:@"size"];
                    }
                    if (needSuffix) {
                        NSString *filename = [rep filename];
                        NSString *suffix = [filename substringWithRange:NSMakeRange([filename rangeOfString:@"."].location + 1, [filename length] - [filename rangeOfString:@"."].location - 1)];
                        [dic setObject:[suffix lowercaseString] forKey:@"suffix"];
                    }
                    if (needMd5)
                        [dic setObject:[[rep md5] lowercaseString] forKey:@"md5"];
                    if (needData) {
                        [dic setObject:[rep toNSData] forKey:@"data"];
                    }
                    if (needDimension) {
                        [dic setObject:[NSValue valueWithCGSize:rep.dimensions] forKey:@"dimension"];
                    }
                }
                else {
                    blockError = [NSError errorWithDomain:@"test" code:0 userInfo:@{@"message" : @"图库文件无法读取"}];
                }
            }
            @finally {
                dispatch_semaphore_signal(semaphore);
            }
        };
        //
        ALAssetsLibraryAccessFailureBlock failureblock = ^(NSError *myerror) {
            blockError = [NSError errorWithDomain:@"test" code:0 userInfo:@{@"message" : @"图库文件无法读取"}];
        };


        ALAssetsLibrary *assetslibrary = [[ALAssetsLibrary alloc] init];
        [assetslibrary assetForURL:self
                       resultBlock:resultblock
                      failureBlock:failureblock];
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    if (blockError) {
        [dic setObject:blockError forKey:@"error"];
    }
    return dic;
}


- (void)assetToFile:(NSString *)filePath {
    //创建一个信号量，等待图库读取完我们才
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    ALAssetsLibraryAssetForURLResultBlock resultBlock = ^(ALAsset *myAsset) {
        @try {
            ALAssetRepresentation *rep = [myAsset defaultRepresentation];
            if (rep) {
                NSError *error = nil;
                if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
                }
                NSLog(@"%@", filePath);
                if (error) {
//                    DLog(@"%@", error);
                }
                [rep toFile:filePath];
            }
        }
        @finally {
            dispatch_semaphore_signal(semaphore);
        }

    };
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *myError) {
//        DLog(@"cant get image - %@", [myError localizedDescription]);
    };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        [assetsLibrary assetForURL:self
                       resultBlock:resultBlock
                      failureBlock:failureBlock];
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

@end