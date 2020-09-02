//
//  UITextView+WKJKit.m
//  WKJKit
//
//  Created by zed.wang on 2019/8/2.
//  Copyright © 2019 zed.wangx. All rights reserved.
//

#import "UITextView+WKJKit.h"
#import "WKJCommonDefine.h"
#import "NSObject+WKJKit.h"
#import "UIView+WKJKit.h"

@interface UITextView ()

@property (nonatomic, strong) UITextView *wkj_placeholderView;
@property (nonatomic, assign) BOOL wkj_shouldAutoHeight;
@property (nonatomic, assign) CGFloat wkj_maxHeight;
@property (nonatomic, assign) CGFloat wkj_initHeight;

@property (nonatomic, copy) WKJTextViewHeightDidChangedBlock wkj_heightChangeHandler;

@end

@implementation UITextView (WKJKit)

+ (void)load
{
    WKJAspectHandler handler = ^(id<WKJAspectMeta>  _Nonnull aspectMeta) {
        UITextView *textView = (UITextView *)aspectMeta.target;
        
        Weakify(textView);
        [textView wkj_addObserverForKeyPaths:textView.wkj_kvoProperties handler:^(NSString * _Nonnull path, id  _Nonnull oldVal, id  _Nonnull newVal) {
            [weak_textView wkj_refreshPlaceholderView];
        }];

        [[NSNotificationCenter defaultCenter] addObserver:textView selector:@selector(wkj_refreshContentHeight) name:UITextViewTextDidChangeNotification object:nil];
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

- (void)wkj_autoHeightWithMaxHeight:(CGFloat)maxHeight didChanged:(nullable WKJTextViewHeightDidChangedBlock)didChanged
{
    self.wkj_shouldAutoHeight = YES;
    self.wkj_maxHeight = MAX(maxHeight, self.wkj_height);
    self.wkj_initHeight = self.wkj_height;
    self.wkj_heightChangeHandler = didChanged;
}

#pragma mark - set && get
WKJBOOLPropertySynthesizer(wkj_shouldAutoHeight, setWkj_shouldAutoHeight)
WKJCGFloatPropertySynthesizer(wkj_maxHeight, setWkj_maxHeight)
WKJCGFloatPropertySynthesizer(wkj_initHeight, setWkj_initHeight)
WKJCopyPropertySynthesizer(wkj_heightChangeHandler, setWkj_heightChangeHandler)
WKJStrongPropertySynthesizer(wkj_placeholderView, setWkj_placeholderView)

WKJIntegerPropertySynthesizer(wkj_textLimit, setWkj_textLimit)

- (void)setWkj_placeholder:(NSString *)placeholder
{
    if (!self.wkj_placeholderView) {
        self.wkj_placeholderView = [self wkj_createPlaceholderView];
        [self wkj_refreshPlaceholderView];
    }
    self.wkj_placeholderView.hidden = !placeholder.length;
    self.wkj_placeholderView.text = placeholder;
}

- (NSString *)wkj_placeholder
{
    return self.wkj_placeholderView.text;
}

- (void)setWkj_placeholderColor:(UIColor *)wkj_placeholderColor
{
    self.wkj_placeholderView.textColor = wkj_placeholderColor;
}

- (UIColor *)wkj_placeholderColor
{
    return self.wkj_placeholderView.textColor;
}

#pragma mark - Private Methods
- (UITextView *)wkj_createPlaceholderView
{
    // 为了让占位文字和textView的实际文字位置能够完全一致，这里用UITextView
    UITextView *placeholderView = [[UITextView alloc] initWithFrame:self.bounds];;
    placeholderView.scrollEnabled = placeholderView.userInteractionEnabled = NO;
    placeholderView.textColor = [UIColor lightGrayColor];
    placeholderView.backgroundColor = [UIColor clearColor];
    placeholderView.hidden = YES;
    [self addSubview:placeholderView];
    return placeholderView;
}

- (NSArray *)wkj_kvoProperties
{
    static char kKvoPropertiesAssociatedObject;
    NSArray *ps = objc_getAssociatedObject(self, &kKvoPropertiesAssociatedObject);
    if (!ps) {
        // 监听text是因为直接赋值的情况
        ps = @[@"frame", @"bounds", @"font", @"text", @"textAlignment", @"textContainerInset"];
        objc_setAssociatedObject(self, &kKvoPropertiesAssociatedObject, ps, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return ps;
}

- (void)wkj_refreshPlaceholderView
{
    self.wkj_placeholderView.frame = self.bounds;
    self.wkj_placeholderView.font = self.font;
    self.wkj_placeholderView.textAlignment = self.textAlignment;
    self.wkj_placeholderView.textContainerInset = self.textContainerInset;
    [self wkj_refreshContentHeight];
}

- (void)wkj_refreshContentHeight
{
    if (self.wkj_textLimit > 0
        && self.text.length > self.wkj_textLimit
        && ![self markedTextRange]) {
        self.text = [self.text substringToIndex:self.wkj_textLimit];
    }
    
    self.wkj_placeholderView.hidden = self.text.length;
    if (!self.wkj_shouldAutoHeight) return;
    
    CGFloat height = ceil([self sizeThatFits:CGSizeMake(self.wkj_width, MAXFLOAT)].height);
    height = height > self.wkj_maxHeight ? self.wkj_maxHeight : height;
    height = height < self.wkj_initHeight ? self.wkj_initHeight : height;
    if (height == self.wkj_height) return;
    
    self.wkj_height = height;
    !self.wkj_heightChangeHandler ?: self.wkj_heightChangeHandler(self.wkj_height);
}

@end
