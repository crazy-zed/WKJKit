//
//  UIButton+WKJKit.m
//  WKJKit
//
//  Created by zed.wang on 2019/7/10.
//  Copyright © 2019 zed.wangx. All rights reserved.
//

#import "UIButton+WKJKit.h"

@implementation UIButton (WKJKit)

- (void)wkj_setImageAliment:(WKJButtonImageAliment)aliment margen:(CGFloat)margen
{
    CGFloat imageWith = self.imageView.image.size.width;
    CGFloat imageHeight = self.imageView.image.size.height;
    
    CGFloat labelWidth = self.titleLabel.intrinsicContentSize.width;
    CGFloat labelHeight = self.titleLabel.intrinsicContentSize.height;
    
    switch (aliment) {
        case WKJButtonImageAlimentLeft: {
            self.titleEdgeInsets = UIEdgeInsetsMake(0, margen/2.f, 0, -margen/2.f);
            self.imageEdgeInsets = UIEdgeInsetsMake(0, -margen/2.f, 0, margen/2.f);
        }
            break;
            
        case WKJButtonImageAlimentRight: {
            self.titleEdgeInsets = UIEdgeInsetsMake(0, -imageWith - margen/2.f, 0, imageWith + margen/2.f);
            self.imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth + margen/2.f, 0, -labelWidth - margen/2.f);
        }
            break;
            
        case WKJButtonImageAlimentTop: {
            self.titleEdgeInsets = UIEdgeInsetsMake(0, -imageWith, -imageHeight - margen/2.f, 0);
            self.imageEdgeInsets = UIEdgeInsetsMake(-labelHeight - margen/2.f, 0, 0, -labelWidth);
        }
            break;
            
        case WKJButtonImageAlimentBottom: {
            self.titleEdgeInsets = UIEdgeInsetsMake(-imageHeight - margen/2.f, -imageWith, 0, 0);
            self.imageEdgeInsets = UIEdgeInsetsMake(0, 0, -labelHeight - margen/2.f, -labelWidth);
        }
            break;
    }
}

@end
