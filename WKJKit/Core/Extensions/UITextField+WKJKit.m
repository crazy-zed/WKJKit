//
//  UITextField+WKJKit.m
//  WKJKit
//
//  Created by zed.wang on 2019/8/12.
//  Copyright © 2019 zed.wangx. All rights reserved.
//

#import "UITextField+WKJKit.h"
#import "WKJCommonDefine.h"
#import "NSObject+WKJKit.h"

@implementation UITextField (WKJKit)

WKJIntegerPropertySynthesizer(wkj_textLimit, setWkj_textLimit)

+ (void)load
{
    WKJAspectHandler handler = ^(id<WKJAspectMeta>  _Nonnull aspectMeta) {
        UITextField *textField = (UITextField *)aspectMeta.target;
        
        Weakify(textField);
        [textField wkj_addObserverForKeyPath:@"text" handler:^(NSString * _Nonnull path, id  _Nonnull oldVal, id  _Nonnull newVal) {
            [weak_textField wkj_textDidChange];
        }];

        [[NSNotificationCenter defaultCenter] addObserver:textField selector:@selector(wkj_textDidChange) name:UITextFieldTextDidChangeNotification object:nil];
    };
    
    [self wkj_hookSelector:@selector(initWithFrame:) withPosition:WKJAspectPositionAfter usingBlock:handler];
    [self wkj_hookSelector:@selector(initWithCoder:) withPosition:WKJAspectPositionAfter usingBlock:handler];
    
    Method dealoc = class_getInstanceMethod(self.class, NSSelectorFromString(@"dealloc"));
    Method myDealloc = class_getInstanceMethod(self.class, @selector(wkj_dealloc));
    method_exchangeImplementations(dealoc, myDealloc);
}

- (void)wkj_dealloc
{
    [self wkj_removeAllObservers];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self wkj_dealloc];
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

#pragma mark -Private
- (void)wkj_textDidChange
{
    if ([self markedTextRange]) return;
    
    if (self.wkj_textLimit > 0 && self.text.length > self.wkj_textLimit) {
        self.text = [self.text substringToIndex:self.wkj_textLimit];
    }
}

@end
