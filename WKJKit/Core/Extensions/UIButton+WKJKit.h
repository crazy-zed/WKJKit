//
//  UIButton+WKJKit.h
//  WKJKit
//
//  Created by zed.wang on 2019/7/10.
//  Copyright © 2019 zed.wangx. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (WKJKit)

/**
 设置图片在上文字在下，必须在设置过title后调用

 @param margen 图文间隙
 */
- (void)setImageAlimentAboveWithMargen:(CGFloat)margen;

@end

NS_ASSUME_NONNULL_END
