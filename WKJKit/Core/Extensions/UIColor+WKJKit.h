//
//  UIColor+WKJKit.h
//
//  Created by 王恺靖 on 2019/4/19.
//  Copyright © 2019 wkj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (WKJKit)

+ (UIColor *)colorWithHexString:(NSString *)str alpha:(CGFloat)alpha;

- (UIColor *)colorWithAlpha:(CGFloat)alpha;

@end
