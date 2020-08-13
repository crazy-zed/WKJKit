//
//  UIButton+WKJKit.m
//  WKJKit
//
//  Created by zed.wang on 2019/7/10.
//  Copyright © 2019 zed.wangx. All rights reserved.
//

#import "UIButton+WKJKit.h"

@implementation UIButton (WKJKit)

- (void)setImageAlimentAboveWithMargen:(CGFloat)margen
{
    self.titleEdgeInsets = UIEdgeInsetsMake(0, -self.imageView.frame.size.width, -self.imageView.frame.size.height-margen/2, 0);
    self.imageEdgeInsets = UIEdgeInsetsMake(-self.titleLabel.intrinsicContentSize.height-margen/2, 0, 0, -self.titleLabel.intrinsicContentSize.width);
}

@end
