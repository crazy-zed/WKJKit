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

@property(nonatomic, assign) IBInspectable CGFloat wkj_cornerRadius;
@property(nonatomic, assign) IBInspectable CGFloat wkj_borderWidth;
@property(nonatomic, strong) IBInspectable UIColor *wkj_borderColor;

@property(nonatomic, assign) IBInspectable CGFloat wkj_shadowRadius;
@property(nonatomic, assign) IBInspectable CGFloat wkj_shadowOpacity;
@property(nonatomic, assign) IBInspectable UIColor *wkj_shadowColor;

@property (assign, nonatomic) CGFloat wkj_x;
@property (assign, nonatomic) CGFloat wkj_y;
@property (assign, nonatomic) CGPoint wkj_origin;

@property (assign, nonatomic) CGFloat wkj_width;
@property (assign, nonatomic) CGFloat wkj_height;
@property (assign, nonatomic) CGSize  wkj_size;

@property (assign, nonatomic) CGFloat wkj_centerX;
@property (assign, nonatomic) CGFloat wkj_centerY;

@property (nonatomic, strong, readonly) UIViewController *wkj_responesVC;

- (void)wkj_addGradientColors:(NSArray<UIColor *> *)colors direct:(WKJGradientDirection)direct;

- (void)wkj_removeGradientColor;

- (void)wkj_addCornerWithRadius:(CGFloat)radius type:(UIRectCorner)type;

@end

@interface UIControl (WKJKit)

@property (nonatomic, assign) UIEdgeInsets wkj_responseEdge;

@end
