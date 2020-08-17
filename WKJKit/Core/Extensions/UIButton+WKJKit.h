//
//  UIButton+WKJKit.h
//  WKJKit
//
//  Created by zed.wang on 2019/7/10.
//  Copyright © 2019 zed.wangx. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, WKJButtonImageAliment) {
    WKJButtonImageAlimentLeft,
    WKJButtonImageAlimentRight,
    WKJButtonImageAlimentTop,
    WKJButtonImageAlimentBottom
};

@interface UIButton (WKJKit)

/// 设置图片文字排版方式
/// @param aliment 图片排版方式
/// @param margen 图文间隙
- (void)wkj_setImageAliment:(WKJButtonImageAliment)aliment margen:(CGFloat)margen;

@end

NS_ASSUME_NONNULL_END
