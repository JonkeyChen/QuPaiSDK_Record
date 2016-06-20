//
//  ALAssetRepresentation+extend.m
//  PictureUploadSDKDemo
//
//  Created by huamulou on 14-11-14.
//  Copyright (c) 2014年 showmethemoney. All rights reserved.
//
#import <CommonCrypto/CommonDigest.h>
#import "ALAssetRepresentation+extend.h"

const unsigned int kTFEDEMOChunkSize = 256 * 1024;

@implementation ALAssetRepresentation (extend)

- (NSString *)md5 {
    CC_MD5_CTX md5;

    CC_MD5_Init(&md5);

    uint8_t *buffer = calloc(kTFEDEMOChunkSize, sizeof(*buffer));
    NSUInteger offset = 0, bytesRead = 0;

    do {
        @try {
            bytesRead = [self getBytes:buffer fromOffset:offset length:kTFEDEMOChunkSize error:nil];
            NSData *bufferData = [NSData dataWithBytesNoCopy:buffer length:bytesRead freeWhenDone:NO];

            CC_MD5_Update(&md5, [bufferData bytes], (unsigned int) [bufferData length]);
            offset += bytesRead;
        } @catch (NSException *exception) {
            free(buffer);

            return nil;
        }
    } while (bytesRead > 0);
    free(buffer);
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    NSString *s = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                                             digest[0], digest[1],
                                             digest[2], digest[3],
                                             digest[4], digest[5],
                                             digest[6], digest[7],
                                             digest[8], digest[9],
                                             digest[10], digest[11],
                                             digest[12], digest[13],
                                             digest[14], digest[15]];
    return s;
}

- (NSData *)toNSData {
    NSError *readError = nil;
    Byte *buffer = (Byte *) malloc((unsigned long) self.size);
    NSUInteger buffered = [self getBytes:buffer fromOffset:0.0 length:(unsigned long) self.size error:&readError];
    NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];//this is NSData may be what you want
    if (readError) {
//        DLog("%@", readError);
        return nil;
    }
    return data;
}


- (void)toFile:(NSString *)filePath {
    // Create a file handle to write the file at your destination path
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    if (!handle) {
        // Handle error here…
    }
    NSError *error = nil;
    // Create a buffer for the asset
    static const NSUInteger BufferSize = 1024 * 1024;
    uint8_t *buffer = calloc(BufferSize, sizeof(*buffer));
    NSUInteger offset = 0, bytesRead = 0;

    // Read the buffer and write the data to your destination path as you go
    do {
        @try {
            bytesRead = [self getBytes:buffer fromOffset:offset length:BufferSize error:&error];
            [handle writeData:[NSData dataWithBytesNoCopy:buffer length:bytesRead freeWhenDone:NO]];
            offset += bytesRead;
        }
        @catch (NSException *exception) {
            free(buffer);

        }
    } while (bytesRead > 0);

    // 
    free(buffer);
}


@end
