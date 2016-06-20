//
//  UIView+Extend.m
//  media.sdk.ios.demo.base
//
//  Created by huamulou on 15/10/16.
//  Copyright © 2015年 alibaba. All rights reserved.
//

#import "UIView+Extend.h"


@implementation UIView (Extend)
- (UIViewController *)viewController {
    /// Finds the view's view controller.
    
    // Traverse responder chain. Return first found view controller, which will be the view's view controller.
    UIResponder *responder = self;
    while ((responder = [responder nextResponder]))
        if ([responder isKindOfClass: [UIViewController class]])
            return (UIViewController *)responder;
    
    // If the view controller isn't found, return nil.
    return nil;
}


@end
