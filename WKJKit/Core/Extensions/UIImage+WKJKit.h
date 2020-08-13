//
//  UIImage+WKJKit.h
//
//  Created by 王恺靖 on 2019/3/11.
//  Copyright © 2019 wkj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (WKJKit)

/// 创建一张纯色图片
+ (UIImage *)imageWithColor:(UIColor *)color;

/// 根据base64生成图片
+ (UIImage *)imageWithBase64:(NSString *)imgBase64;

/// 创建一张屏幕截图
+ (UIImage *)createScreenShootImage;

/// 创建一张View截图
+ (UIImage *)createViewShootWithView:(UIView *)view;

/// 缩放图片，0.0 < scale < 1.0
- (UIImage *)scale:(float)scale;

/// 改变图片尺寸
- (UIImage *)reSize:(CGSize)reSize;

/// 返回圆形图片
- (UIImage *)circleImage;

/// 根据图片名返回圆形图片
+ (UIImage *)circleImageWithName:(NSString *)name;

/// 返回原图片
- (UIImage *)originalImage;

/// 返回样板图片
- (UIImage *)templateImage;

/// 返回高斯模糊图片
- (UIImage *)blurryImageWithLevel:(CGFloat)level;

/// 修正图片转向
+ (UIImage *)fixOrientation:(UIImage *)aImage;

@end

