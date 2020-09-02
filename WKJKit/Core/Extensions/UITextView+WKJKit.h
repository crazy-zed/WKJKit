//
//  UITextView+WKJKit.h
//  WKJKit
//
//  Created by zed.wang on 2019/8/2.
//  Copyright © 2019 zed.wangx. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^WKJTextViewHeightDidChangedBlock)(CGFloat textViewHeight);

@interface UITextView (WKJKit)

/// 占位文字
@property (nonatomic, copy) IBInspectable NSString *wkj_placeholder;

/// 占位文字颜色
@property (nonatomic, strong) IBInspectable UIColor *wkj_placeholderColor;

/// 文字字数限制
@property (nonatomic, assign) IBInspectable NSInteger wkj_textLimit;

/// 设置自适应高度
/// @param maxHeight 最大高度
/// @param didChanged 高度改变回调
- (void)wkj_autoHeightWithMaxHeight:(CGFloat)maxHeight didChanged:(nullable WKJTextViewHeightDidChangedBlock)didChanged;

@end

NS_ASSUME_NONNULL_END
