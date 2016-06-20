//
//  MyAlertView.h
//  UniversalAccount
//
//  Created by shaobin on 3/25/14.
//  Copyright (c) 2014 alipay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyAlertView : UIAlertView<UIAlertViewDelegate>

+ (MyAlertView *)alertViewWithTitle:(NSString *)title
                             message:(NSString *)message
                        onBtnClicked:(void(^)(NSInteger btnIndex))onBtnClicked
                   cancelButtonTitle:(NSString *)cancelButtonTitle
                   otherButtonTitles:(NSString *)otherButtonTitles, ...;

@end
