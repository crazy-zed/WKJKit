//
//  UIColor+WKJKit.m
//
//  Created by 王恺靖 on 2019/4/19.
//  Copyright © 2019 wkj. All rights reserved.
//

#import "UIColor+WKJKit.h"

@implementation UIColor (WKJKit)

+ (UIColor *)wkj_colorWithHex:(NSString *)str alpha:(CGFloat)alpha
{
    // 去除空格并大写
    str = [[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([str length] < 6) {
        return [UIColor clearColor];
    }
    
    // 判断前缀
    if ([str hasPrefix:@"0X"])
        str = [str substringFromIndex:2];
    if ([str hasPrefix:@"#"])
        str = [str substringFromIndex:1];
    if ([str length] != 6)
        return [UIColor clearColor];
    
    // 从六位数值中找到RGB对应的位数并转换
    NSRange range = NSMakeRange(0, 2);
    NSString *R = [str substringWithRange:range];
    range.location = 2;
    NSString *G = [str substringWithRange:range];
    range.location = 4;
    NSString *B = [str substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:R] scanHexInt:&r];
    [[NSScanner scannerWithString:G] scanHexInt:&g];
    [[NSScanner scannerWithString:B] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:alpha];
}

- (UIColor *)wkj_colorWithAlpha:(CGFloat)alpha
{
    CGFloat red = 0.0, green = 0.0, blue = 0.0, colorAlpha = 0.0;
    if ([self respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
        [self getRed:&red green:&green blue:&blue alpha:&colorAlpha];
        return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    } else {
        return UIColor.clearColor;
    }
}

@end
