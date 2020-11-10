//
//  WKJAlert.m
//  WKJVideo
//
//  Created by zed.wang on 2019/8/27.
//  Copyright © 2019 zed.wang. All rights reserved.
//

#import "WKJAlert.h"
#import "WKJCommonDefine.h"
#import "UIView+WKJKit.h"

#import <Masonry/Masonry.h>

@interface WKJAlert ()

@property (nonatomic, strong) UIView          *maskView;
@property (nonatomic, strong) UIImageView     *topImageView;
@property (nonatomic, strong) UILabel         *titleLabel;
@property (nonatomic, strong) UILabel         *contentLabel;
@property (nonatomic, strong) UIView          *customView;
@property (nonatomic, strong) WKJAlertAction   *cancelBtn;
@property (nonatomic, strong) WKJAlertAction   *confirmBtn;

@property (nonatomic, strong) UIImageView     *horLine;
@property (nonatomic, strong) UIImageView     *varLine;

@end

@implementation WKJAlert

NSMutableArray  *alertList;

#pragma mark - Init
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initProperties];
        [self setupViews];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initProperties];
        [self setupViews];
    }
    return self;
}

- (void)initProperties
{
    self.maskColor = UIRGBColor(0, 0, 0, 0.5);
    self.lineColor = UIHexColor(@"#EDEDED", 1);
    
    self.titleColor = UIHexColor(@"#333333", 1);
    self.titleFont = UINormalFont(15);
    self.titleTextAlignment = NSTextAlignmentCenter;
    
    self.contentColor = UIHexColor(@"#666666", 1);
    self.contentFont = UINormalFont(14);
    self.contentTextAlignment = NSTextAlignmentCenter;
    
    self.confirmActionTitleFont = UINormalFont(14);
    self.confirmActionTitleColor = UIColor.blueColor;
    
    self.cancleActionTitleFont = UINormalFont(14);
    self.cancleActionTitleColor = UIHexColor(@"#999999", 1);
}

- (void)setupViews
{
    self.layer.cornerRadius = 8.f;
    
    [self.topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.mas_top);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topImageView.mas_bottom).offset(10);
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(10);
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
    }];
    
    [self.horLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentLabel.mas_bottom).offset(25);
        make.left.right.equalTo(self).offset(0);
        make.height.mas_equalTo(0.5);
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.cancelBtn wkj_addCornerWithRadius:8.f type:UIRectCornerBottomLeft|UIRectCornerBottomRight];
    [self.confirmBtn wkj_addCornerWithRadius:8.f type:UIRectCornerBottomLeft|UIRectCornerBottomRight];
}

#pragma mark - Show & Hide
+ (void)showWithTitle:(nullable NSString *)title
               cancel:(nullable WKJAlertAction *)cancel
              confirm:(nullable WKJAlertAction *)confirm
{
    [self showWithTitle:title content:nil cancel:cancel confirm:confirm];
}

+ (void)showWithContent:(nullable NSString *)content
                 cancel:(nullable WKJAlertAction *)cancel
                confirm:(nullable WKJAlertAction *)confirm
{
    [self showWithTitle:nil content:content cancel:cancel confirm:confirm];
}

+ (void)showWithTitle:(nullable NSString *)title
              content:(nullable NSString *)content
               cancel:(nullable WKJAlertAction *)cancel
              confirm:(nullable WKJAlertAction *)confirm
{
    [self showWithImage:nil title:title content:content cancel:cancel confirm:confirm];
}

+ (void)showWithImage:(UIImage *)image
                title:(NSString *)title
              content:(NSString *)content
               cancel:(WKJAlertAction *)cancel
              confirm:(WKJAlertAction *)confirm
{
    if (!cancel && !confirm) return;
    
    WKJAlert *alert = [[WKJAlert alloc] init];
    alert.backgroundColor = UIColor.whiteColor;
    
    alert.topImageView.hidden = !image;
    alert.titleLabel.hidden = !title.length;
    alert.contentLabel.hidden = !content.length;
    alert.varLine.hidden = (!cancel || !confirm);
    
    alert.topImageView.image = image;
    alert.titleLabel.text = title;
    alert.contentLabel.text = content;
    alert.cancelBtn = cancel;
    alert.confirmBtn = confirm;
    
    alert.titleLabel.font = alert.titleFont;
    alert.titleLabel.textColor = alert.titleColor;
    alert.titleLabel.textAlignment = alert.titleTextAlignment;
    
    alert.contentLabel.font = alert.contentFont;
    alert.contentLabel.textColor = alert.contentColor;
    alert.contentLabel.textAlignment = alert.contentTextAlignment;
    
    alert.cancelBtn.titleLabel.font = alert.cancleActionTitleFont;
    [alert.cancelBtn setTitleColor:alert.cancleActionTitleColor forState:UIControlStateNormal];
    
    alert.confirmBtn.titleLabel.font = alert.confirmActionTitleFont;
    [alert.confirmBtn setTitleColor:alert.confirmActionTitleColor forState:UIControlStateNormal];
    
    alert.maskView.backgroundColor = alert.maskColor;
    alert.horLine.backgroundColor = alert.lineColor;
    alert.varLine.backgroundColor = alert.lineColor;
    
    [[WKJAlert alertList] addObject:alert];
    [alert startShowAlert];
}

+ (void)showWithCustomView:(UIView *)customView
                    cancel:(nullable WKJAlertAction *)cancel
                   confirm:(nullable WKJAlertAction *)confirm
{
    if (!cancel && !confirm) return;
    
    WKJAlert *alert = [[WKJAlert alloc] init];
    alert.layer.masksToBounds = YES;
    alert.backgroundColor = UIColor.whiteColor;
    
    alert.topImageView.hidden = YES;
    alert.titleLabel.hidden = YES;
    alert.contentLabel.hidden = YES;
    alert.varLine.hidden = (!cancel || !confirm);
    
    alert.customView = customView;
    alert.cancelBtn = cancel;
    alert.confirmBtn = confirm;
    
    alert.cancelBtn.titleLabel.font = alert.cancleActionTitleFont;
    [alert.cancelBtn setTitleColor:alert.cancleActionTitleColor forState:UIControlStateNormal];
    
    alert.confirmBtn.titleLabel.font = alert.confirmActionTitleFont;
    [alert.confirmBtn setTitleColor:alert.confirmActionTitleColor forState:UIControlStateNormal];
    
    alert.maskView.backgroundColor = alert.maskColor;
    alert.horLine.backgroundColor = alert.lineColor;
    alert.varLine.backgroundColor = alert.lineColor;
    
    [[WKJAlert alertList] addObject:alert];
    [alert startShowAlert];
}

+ (void)hide
{
    [self hideWithComplete:nil];
}

+ (void)hideWithComplete:(void(^)(void))complete
{
    WKJAlert *alert = [WKJAlert alertList].firstObject;
    [[WKJAlert alertList] removeObject:alert];
    [alert doPopAnimation:^{
        WKJAlert *next = [WKJAlert alertList].firstObject;
        [next startShowAlert];
        !complete ?: complete();
    }];
}

#pragma mark - Private
- (void)startShowAlert
{
    if (self != [WKJAlert alertList].firstObject) return;
    
    [MAIN_WINDOW addSubview:self.maskView];
    [MAIN_WINDOW addSubview:self];
    
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(MAIN_WINDOW);
    }];
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(MAIN_WINDOW);
        make.left.equalTo(MAIN_WINDOW).offset(45);
        make.right.equalTo(MAIN_WINDOW).offset(-45);
        make.height.mas_greaterThanOrEqualTo(140);
    }];
    
    [self refreshLayout];
    [self layoutIfNeeded];
    [MAIN_WINDOW layoutIfNeeded];
    
    self.maskView.alpha = 0;
    self.alpha = 0;
    [self doPushAnimation:nil];
}

- (void)refreshLayout
{
    if (!self.topImageView.image) {
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(25);
            make.left.equalTo(self).offset(20);
            make.right.equalTo(self).offset(-20);
        }];
    }
    
    if (!self.titleLabel.text.length) {
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(25);
            make.left.equalTo(self).offset(20);
            make.right.equalTo(self).offset(-20);
        }];
    }
    
    if (!self.contentLabel.text.length) {
        [self.horLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).offset(25);
            make.left.right.equalTo(self).offset(0);
            make.height.mas_equalTo(0.5);
        }];
    }
    
    if (self.customView) {
        [self addSubview:self.customView];
        [self.customView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.equalTo(self);
            make.height.mas_equalTo(self.customView.wkj_height);
        }];
        
        [self.horLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.customView.mas_bottom);
            make.left.right.equalTo(self).offset(0);
            make.height.mas_equalTo(0.5);
        }];
    }
    
    if (self.confirmBtn) {
        [self addSubview:self.confirmBtn];
        [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.horLine.mas_bottom);
            make.left.right.equalTo(self).offset(0);
            make.height.mas_equalTo(45);
            make.bottom.equalTo(self);
        }];
    }
    
    if (self.cancelBtn) {
        [self addSubview:self.cancelBtn];
        [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.horLine.mas_bottom);
            make.left.right.equalTo(self).offset(0);
            make.height.mas_equalTo(45);
            make.bottom.equalTo(self);
        }];
    }
    
    if (self.confirmBtn && self.cancelBtn) {
        [self.varLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.top.equalTo(self.horLine.mas_bottom);
            make.bottom.equalTo(self);
            make.width.mas_equalTo(0.5);
        }];
        
        [self.cancelBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.horLine.mas_bottom);
            make.left.equalTo(self).offset(0);
            make.right.equalTo(self.varLine.mas_left);
            make.height.mas_equalTo(45);
            make.bottom.equalTo(self);
        }];
        
        [self.confirmBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.horLine.mas_bottom);
            make.left.equalTo(self.varLine.mas_right);
            make.right.equalTo(self).offset(0);
            make.height.mas_equalTo(45);
            make.bottom.equalTo(self);
        }];
    }
}

- (void)doPushAnimation:(void(^)(void))complete
{
    self.transform = CGAffineTransformMakeScale(1.2, 1.2);
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.transform = CGAffineTransformMakeScale(1, 1);
        self.alpha = 1.f;
        self.maskView.alpha = 1.f;
    } completion:^(BOOL finished) {
        !complete ?: complete();
    }];
}

- (void)doPopAnimation:(void(^)(void))complete
{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.alpha = 0;
        self.maskView.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self.maskView removeFromSuperview];
        !complete ?: complete();
    }];
}

#pragma mark - Lazy Load
+ (NSMutableArray *)alertList
{
    if (!alertList) {
        alertList = @[].mutableCopy;
    }
    return alertList;
}

- (UIView *)maskView
{
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
    }
    return _maskView;
}

- (UIImageView *)topImageView
{
    if (!_topImageView) {
        _topImageView = [UIImageView new];
        _topImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_topImageView];
    }
    return _topImageView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.numberOfLines = 0;
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)contentLabel
{
    if (!_contentLabel) {
        _contentLabel = [UILabel new];
        _contentLabel.numberOfLines = 0;
        [self addSubview:_contentLabel];
    }
    return _contentLabel;
}

- (UIImageView *)horLine
{
    if (!_horLine) {
        _horLine = [UIImageView new];
        [self addSubview:_horLine];
    }
    return _horLine;
}

- (UIImageView *)varLine
{
    if (!_varLine) {
        _varLine = [UIImageView new];
        [self addSubview:_varLine];
    }
    return _varLine;
}

@end


@implementation WKJAlertAction
{
    WKJAlertActionHandler    _actionHandler;
    BOOL                    _autoHide;
}

+ (instancetype)actionWithTitle:(NSString *)title handler:(WKJAlertActionHandler)handler
{
    return [WKJAlertAction actionWithTitle:title autoHide:YES handler:handler];
}

+ (instancetype)actionWithTitle:(NSString *)title autoHide:(BOOL)autoHide handler:(nullable WKJAlertActionHandler)handler
{
    WKJAlertAction *actionBtn = [WKJAlertAction buttonWithType:UIButtonTypeCustom];
    [actionBtn setTitle:title forState:UIControlStateNormal];
    [actionBtn addTarget:actionBtn action:@selector(actionBtnClick) forControlEvents:UIControlEventTouchUpInside];
    actionBtn->_actionHandler = handler;
    actionBtn->_autoHide = autoHide;
    return actionBtn;
}

- (void)actionBtnClick
{
    !_actionHandler ?: _actionHandler();
    if (_autoHide) {
        [WKJAlert hide];
    }
}

@end
