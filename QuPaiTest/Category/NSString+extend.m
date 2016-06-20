//
// Created by huamulou on 15-1-25.
// Copyright (c) 2015 alibaba. All rights reserved.


#import "NSString+extend.h"


@implementation NSString(extend)

+ (NSString*) uniqueString{
    
    CFUUIDRef	uuidObj = CFUUIDCreate(nil);
    NSString	*uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    return [uuidString stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

@end