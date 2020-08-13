//
//  UIView+WKJKit.h
//
//  Created by 王恺靖 on 2019/4/9.
//  Copyright © 2019 wkj. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, WKJGradientDirection) {
    WKJGradientDirectionHorizontal,
    WKJGradientDirectionVertical
};

@interface UIView (WKJKit)

@property(nonatomic, assign) IBInspectable CGFloat cornerRadius;
@property(nonatomic, assign) IBInspectable CGFloat borderWidth;
@property(nonatomic, strong) IBInspectable UIColor *borderColor;

@property(nonatomic, assign) IBInspectable CGFloat shadowRadius;
@property(nonatomic, assign) IBInspectable CGFloat shadowOpacity;
@property(nonatomic, assign) IBInspectable UIColor *shadowColor;

@property (assign, nonatomic) CGFloat x;
@property (assign, nonatomic) CGFloat y;
@property (assign, nonatomic) CGPoint origin;

@property (assign, nonatomic) CGFloat width;
@property (assign, nonatomic) CGFloat height;
@property (assign, nonatomic) CGSize  size;

@property (assign, nonatomic) CGFloat centerX;
@property (assign, nonatomic) CGFloat centerY;

@property (nonatomic, strong, readonly) UIViewController *responesVC;

- (void)addGradientColor:(UIColor *)color to:(UIColor *)toColor dir:(WKJGradientDirection)dir;

- (void)removeGradientColor;

- (void)addCornerWithRadius:(CGFloat)radius type:(UIRectCorner)type;

@end
