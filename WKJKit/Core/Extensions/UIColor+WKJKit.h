//
//  UIColor+WKJKit.h
//
//  Created by 王恺靖 on 2019/4/19.
//  Copyright © 2019 wkj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (WKJKit)

+ (UIColor *)wkj_colorWithHex:(NSString *)str alpha:(CGFloat)alpha;

- (UIColor *)wkj_colorWithAlpha:(CGFloat)alpha;

@end
