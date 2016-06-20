//
//  UITableViewCell+FixUITableViewCellAutolayout.m
//  Created by huamulou on 14-11-17.
//  Copyright (c) 2014年 alibaba. All rights reserved.
//
#import <objc/runtime.h>
#import <objc/message.h>
#import "UITableViewCell+FixUITableViewCellAutolayout.h"

@implementation UITableViewCell (FixUITableViewCellAutolayout)


+ (void)load
{
    Method existing = class_getInstanceMethod(self, @selector(layoutSubviews));
    Method new = class_getInstanceMethod(self, @selector(_autolayout_replacementLayoutSubviews));
    
    method_exchangeImplementations(existing, new);
}

- (void)_autolayout_replacementLayoutSubviews
{
    [super layoutSubviews];
    [self _autolayout_replacementLayoutSubviews]; // not recursive due to method swizzling
    [super layoutSubviews];
}
@end
