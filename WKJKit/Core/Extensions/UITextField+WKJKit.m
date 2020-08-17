//
//  UITextField+WKJKit.m
//  WKJKit
//
//  Created by zed.wang on 2019/8/12.
//  Copyright © 2019 zed.wangx. All rights reserved.
//

#import "UITextField+WKJKit.h"
#import "NSObject+WKJKit.h"

@implementation UITextField (WKJKit)

+ (void)load
{
    [self wkj_hookSelector:NSSelectorFromString(@"dealloc") withPosition:WKJAspectPositionBefore usingBlock:^(id<WKJAspectMeta>  _Nonnull aspectMeta) {
        [aspectMeta.target removeObserver:aspectMeta.target forKeyPath:@"text"];
        [[NSNotificationCenter defaultCenter] removeObserver:aspectMeta.target];
    }];
}

- (UIColor *)wkj_placeholderColor
{
    NSRange range = NSMakeRange(0, self.attributedPlaceholder.length);
    return [self.attributedPlaceholder attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:&range];
}

- (void)setWkj_placeholderColor:(UIColor *)placeholderColor
{
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:self.placeholder];
    [attr setAttributes:@{NSFontAttributeName:self.font, NSForegroundColorAttributeName:placeholderColor} range:NSMakeRange(0, self.placeholder.length)];
    self.attributedPlaceholder = attr;
}

@end
