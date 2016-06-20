//
//  NSString+Utility.h
//  SaleHouse
//
//  Created by 苏军朋 on 15-1-5.
//  Copyright (c) 2015年 苏军朋. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Utility)

-(CGFloat)getStringHeight:(UIFont*)font
                    width:(CGFloat)width;
-(CGFloat)getStringWidth:(UIFont*)font
                  Height:(CGFloat)height;

//特殊字符串计算高度
-(CGFloat)mutableAttributedStringWithFont:(UIFont *)font
                                    width:(CGFloat)width
                             andLineSpace:(CGFloat)lineSpace;

///判断字符串是否有效
-(BOOL)isCurStringValid;

@end
