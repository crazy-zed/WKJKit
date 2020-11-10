//
//  UIView+WKJKit.m
//
//  Created by 王恺靖 on 2019/4/9.
//  Copyright © 2019 wkj. All rights reserved.
//

#import "UIView+WKJKit.h"
#import "WKJCommonDefine.h"
#import "NSObject+WKJKit.h"

@implementation UIView (WKJKit)

- (CGFloat)wkj_cornerRadius
{
    return self.layer.cornerRadius;
}

- (void)setWkj_cornerRadius:(CGFloat)cornerRadius
{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = cornerRadius;
}

- (UIColor *)wkj_borderColor
{
    return [UIColor colorWithCGColor:self.layer.borderColor];
}

- (void)setWkj_borderColor:(UIColor *)borderColor
{
    self.layer.borderColor = borderColor.CGColor;
}

- (CGFloat)wkj_borderWidth
{
    return self.layer.borderWidth;
}

- (void)setWkj_borderWidth:(CGFloat)borderWidth
{
    self.layer.borderWidth = borderWidth;
}

- (CGFloat)wkj_shadowRadius
{
    return self.layer.shadowRadius;
}

- (void)setWkj_shadowRadius:(CGFloat)shadowRadius
{
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowRadius = shadowRadius;
}

- (CGFloat)wkj_shadowOpacity
{
    return self.layer.shadowOpacity;
}

- (void)setWkj_shadowOpacity:(CGFloat)shadowOpacity
{
    self.layer.shadowOpacity = shadowOpacity;
}

- (UIColor *)wkj_shadowColor
{
    return [UIColor colorWithCGColor:self.layer.shadowColor];
}

- (void)setWkj_shadowColor:(UIColor *)shadowColor
{
    self.layer.shadowColor = shadowColor.CGColor;
}

#pragma mark - Frame
- (CGFloat)wkj_x
{
    return self.frame.origin.x;
}

- (void)setWkj_x:(CGFloat)value
{
    CGRect frame = self.frame;
    frame.origin.x = value;
    self.frame = frame;
}

- (CGFloat)wkj_y
{
    return self.frame.origin.y;
}

- (void)setWkj_y:(CGFloat)value
{
    CGRect frame = self.frame;
    frame.origin.y = value;
    self.frame = frame;
}

- (CGPoint)wkj_origin
{
    return self.frame.origin;
}

- (void)setWkj_origin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGFloat)wkj_width
{
    return self.frame.size.width;
}

- (void)setWkj_width:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)wkj_height
{
    return self.frame.size.height;
}

- (void)setWkj_height:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGSize)wkj_size
{
    return self.frame.size;
}

- (void)setWkj_size:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGFloat)wkj_centerX
{
    return self.center.x;
}

- (void)setWkj_centerX:(CGFloat)centerX
{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)wkj_centerY
{
    return self.center.y;
}

- (void)setWkj_centerY:(CGFloat)centerY
{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

#pragma mark - Response
- (UIViewController *)wkj_responesVC
{
    UIResponder *next = [self nextResponder];
    do {
        if ([next isKindOfClass:UIViewController.class]) {
            return (UIViewController *)next;
        }
        next = [next nextResponder];
    } while (next);
    return nil;
}

#pragma mark - Methods
- (void)wkj_addGradientColors:(NSArray<UIColor *> *)colors direct:(WKJGradientDirection)direct
{
    if (!colors.count) return;
    
    [self wkj_removeGradientColor];
    
    CAGradientLayer *gradientLayer  = [[CAGradientLayer alloc] init];
    gradientLayer.frame = self.bounds;
    NSMutableArray *cgColors = @[].mutableCopy;
    for (UIColor *color in colors) {
        [cgColors addObject:(id)color.CGColor];
    }
    gradientLayer.colors = cgColors;
    gradientLayer.startPoint = CGPointMake(0, 0);
    switch (direct) {
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

- (void)wkj_removeGradientColor
{
    CAGradientLayer *gradientLayer = [self gradientLayer];
    if (!gradientLayer) return;
    [gradientLayer removeFromSuperlayer];
    gradientLayer = nil;
}

- (void)wkj_addCornerWithRadius:(CGFloat)radius type:(UIRectCorner)type
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
        if ([sublayer isKindOfClass:CAGradientLayer.class]) {
            return (CAGradientLayer *)sublayer;
        }
    }
    return nil;
}

@end

@implementation UIControl (WKJKit)

WKJInsetsPropertySynthesizer(wkj_responseEdge, setWkj_responseEdge)

+ (void)load
{
    [self wkj_hookSelector:@selector(pointInside:withEvent:) withPosition:WKJAspectPositionInstead usingBlock:^(id<WKJAspectMeta>  _Nonnull aspectMeta) {
        CGPoint point = [aspectMeta.args.firstObject CGPointValue];
        UIEvent *event = aspectMeta.args.lastObject;

        if (event.type != UIEventTypeTouches) {
            [aspectMeta.originalInvocation invoke]; return;
        }

        UIEdgeInsets rspEdge = [aspectMeta.target wkj_responseEdge];
        CGRect bounds = [aspectMeta.target bounds];
        CGSize size = [aspectMeta.target size];
        
        CGRect rspRect = CGRectMake(CGRectGetMinX(bounds) + rspEdge.left,
                                    CGRectGetMinY(bounds) + rspEdge.top,
                                    size.width - (rspEdge.left + rspEdge.right),
                                    size.height - (rspEdge.top + rspEdge.bottom));

        BOOL result = CGRectContainsPoint(rspRect, point);
        [aspectMeta.originalInvocation invoke];
        [aspectMeta.originalInvocation setReturnValue:&result];
    }];
}

@end
