//
//  MyAlertView.m
//  UniversalAccount
//
//  Created by shaobin on 3/25/14.
//  Copyright (c) 2014 alipay. All rights reserved.
//

#import "MyAlertView.h"

@interface MyAlertView()
@property (nonatomic, strong) void (^btnClickCallback)(NSInteger index);
@end

@implementation MyAlertView

+ (MyAlertView *)alertViewWithTitle:(NSString *)title
                            message:(NSString *)message
                       onBtnClicked:(void(^)(NSInteger btnIndex))onBtnClicked
                  cancelButtonTitle:(NSString *)cancelButtonTitle
                  otherButtonTitles:(NSString *)otherButtonTitles, ... {
    MyAlertView *ret = nil;
    if(otherButtonTitles) {
        ret = [[MyAlertView alloc] initWithTitle:title
                                         message:message
                                        delegate:self
                               cancelButtonTitle:cancelButtonTitle
                               otherButtonTitles:otherButtonTitles, nil];
        
        va_list vl;
        va_start(vl, otherButtonTitles);
        NSString *arg = va_arg(vl, NSString*);
        while(arg) {
            arg = va_arg(vl, NSString*);
            [ret addButtonWithTitle:arg];
        }
        va_end(vl);
    } else {
        ret = [[MyAlertView alloc] initWithTitle:title
                                         message:message
                                        delegate:self
                               cancelButtonTitle:cancelButtonTitle
                               otherButtonTitles:nil];
    }
    
    ret.btnClickCallback = onBtnClicked;
    ret.delegate = ret;
    return ret;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(self.btnClickCallback) {
        self.btnClickCallback(buttonIndex);
        self.btnClickCallback = nil;
    }
}

@end