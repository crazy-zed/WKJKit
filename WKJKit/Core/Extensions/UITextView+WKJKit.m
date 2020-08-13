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

@property (nonatomic, assign) BOOL wkj_shouldAutoHeight;
@property (nonatomic, assign) CGFloat wkj_maxHeight;
@property (nonatomic, assign) CGFloat wkj_initHeight;

@property (nonatomic, copy) WKJTextViewHeightDidChangedBlock wkj_heightChangeHandler;

@end

@implementation UITextView (WKJKit)

+ (void)load
{
    [self wkj_hookSelector:NSSelectorFromString(@"dealloc") withPosition:WKJAspectPositionBefore usingBlock:^(id<WKJAspectMeta>  _Nonnull aspectMeta) {
        for (NSString *path in [aspectMeta.target wkj_kvoProperties]) {
            @try {
                [aspectMeta.target removeObserver:aspectMeta.target forKeyPath:path];
            } @catch (NSException *exception) {}
        }
        [[NSNotificationCenter defaultCenter] removeObserver:aspectMeta.target];
    }];
}

- (void)wkj_autoHeightWithMaxHeight:(CGFloat)maxHeight didChanged:(nullable WKJTextViewHeightDidChangedBlock)didChanged
{
    self.wkj_shouldAutoHeight = YES;
    self.wkj_maxHeight = MAX(maxHeight, self.height);
    self.wkj_initHeight = self.height;
    self.wkj_heightChangeHandler = didChanged;
}

#pragma mark - set && get
WKJBOOLPropertySynthesizer(wkj_shouldAutoHeight, setWkj_shouldAutoHeight)
WKJCGFloatPropertySynthesizer(wkj_maxHeight, setWkj_maxHeight)
WKJCGFloatPropertySynthesizer(wkj_initHeight, setWkj_initHeight)
WKJCopyPropertySynthesizer(wkj_heightChangeHandler, setWkj_heightChangeHandler)

- (void)setWkj_placeholder:(NSString *)placeholder
{
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
- (UITextView *)wkj_placeholderView
{
    // 为了让占位文字和textView的实际文字位置能够完全一致，这里用UITextView
    static char kPlaceholderViewAssociatedObject;
    UITextView *placeholderView = objc_getAssociatedObject(self, &kPlaceholderViewAssociatedObject);
    if (!placeholderView) {
        placeholderView = [[UITextView alloc] initWithFrame:self.bounds];
        placeholderView.scrollEnabled = placeholderView.userInteractionEnabled = NO;
        placeholderView.textColor = [UIColor lightGrayColor];
        placeholderView.backgroundColor = [UIColor clearColor];
        [self addSubview:placeholderView];
        
        HandleNotifaction(UITextViewTextDidChangeNotification, @selector(wkj_refreshContentHeight));
        for (NSString *path in self.wkj_kvoProperties) {
            [self addObserver:self forKeyPath:path options:NSKeyValueObservingOptionNew context:nil];
        }
        
        objc_setAssociatedObject(self, &kPlaceholderViewAssociatedObject, placeholderView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    // 同步self的属性
    self.wkj_placeholderView.frame = self.bounds;
    self.wkj_placeholderView.font = self.font;
    self.wkj_placeholderView.textAlignment = self.textAlignment;
    self.wkj_placeholderView.textContainerInset = self.textContainerInset;
    
    if ([keyPath isEqualToString:@"text"]) {
        [self wkj_refreshContentHeight];
    }
}

- (void)wkj_refreshContentHeight
{
    self.wkj_placeholderView.hidden = self.text.length;
    if (!self.wkj_shouldAutoHeight) return;
    
    CGFloat height = ceil([self sizeThatFits:CGSizeMake(self.width, MAXFLOAT)].height);
    height = height > self.wkj_maxHeight ? self.wkj_maxHeight : height;
    height = height < self.wkj_initHeight ? self.wkj_initHeight : height;
    if (height == self.height) return;
    
    self.height = height;
    !self.wkj_heightChangeHandler ?: self.wkj_heightChangeHandler(self.height);
}

@end
