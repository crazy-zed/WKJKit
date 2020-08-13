//
//  UIView+WKJKit.m
//
//  Created by 王恺靖 on 2019/4/9.
//  Copyright © 2019 wkj. All rights reserved.
//

#import "UIView+WKJKit.h"
#import <objc/runtime.h>

@implementation UIView (WKJKit)

- (CGFloat)cornerRadius
{
    return self.layer.cornerRadius;
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = cornerRadius;
}

- (UIColor *)borderColor
{
    return [UIColor colorWithCGColor:self.layer.borderColor];
}

- (void)setBorderColor:(UIColor *)borderColor
{
    self.layer.borderColor = borderColor.CGColor;
}

- (CGFloat)borderWidth
{
    return self.layer.borderWidth;
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    self.layer.borderWidth = borderWidth;
}

- (CGFloat)shadowRadius
{
    return self.layer.shadowRadius;
}

- (void)setShadowRadius:(CGFloat)shadowRadius
{
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowRadius = shadowRadius;
}

- (CGFloat)shadowOpacity
{
    return self.layer.shadowOpacity;
}

- (void)setShadowOpacity:(CGFloat)shadowOpacity
{
    self.layer.shadowOpacity = shadowOpacity;
}

- (UIColor *)shadowColor
{
    return [UIColor colorWithCGColor:self.layer.shadowColor];
}

- (void)setShadowColor:(UIColor *)shadowColor
{
    self.layer.shadowColor = shadowColor.CGColor;
}

#pragma mark - Frame
- (CGFloat)x
{
    return self.frame.origin.x;
}

- (void)setX:(CGFloat)value
{
    CGRect frame = self.frame;
    frame.origin.x = value;
    self.frame = frame;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (void)setY:(CGFloat)value
{
    CGRect frame = self.frame;
    frame.origin.y = value;
    self.frame = frame;
}

- (CGPoint)origin
{
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGSize)size
{
    return self.frame.size;
}

- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGFloat)centerX
{
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX
{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerY
{
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY
{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (UIViewController *)responesVC
{
    for (UIView *next = self.superview; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

#pragma mark - Methods
- (void)addGradientColor:(UIColor *)color to:(UIColor *)toColor dir:(WKJGradientDirection)dir
{
    if (!color || !toColor) return;
    
    [self removeGradientColor];
    
    CAGradientLayer *gradientLayer  = [[CAGradientLayer alloc] init];
    gradientLayer.frame = self.bounds;
    gradientLayer.colors = @[(id)color.CGColor,(id)toColor.CGColor];
    gradientLayer.startPoint = CGPointMake(0, 0);
    switch (dir) {
        case WKJGradientDirectionHorizontal:
            gradientLayer.endPoint = CGPointMake(1, 0);
            break;
            
        case WKJGradientDirectionVertical:
            gradientLayer.endPoint = CGPointMake(0, 1);
            break;
            
        default:
            gradientLayer.endPoint = CGPointMake(1, 0);
            break;
    }
    [self.layer insertSublayer:gradientLayer atIndex:0];
}

- (void)removeGradientColor
{
    CAGradientLayer *gradientLayer = [self gradientLayer];
    if (!gradientLayer) return;
    [gradientLayer removeFromSuperlayer];
    gradientLayer = nil;
}

- (void)addCornerWithRadius:(CGFloat)radius type:(UIRectCorner)type
{
    if (self.layer.mask) {
        [self.layer.mask removeFromSuperlayer];
        self.layer.mask = nil;
    }
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:type cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.frame = self.bounds;
    mask.path = bezierPath.CGPath;
    self.layer.mask = mask;
}

#pragma mark - private
- (CAGradientLayer *)gradientLayer
{
    for (CALayer *sublayer in self.layer.sublayers) {
        if (![sublayer isKindOfClass:CAGradientLayer.class]) {
            continue;
        }
        return (CAGradientLayer *)sublayer;
    }
    return nil;
}

@end
