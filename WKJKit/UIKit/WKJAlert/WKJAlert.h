//
//  WKJAlert.h
//  WKJKit
//
//  Created by zed.wang on 2019/8/27.
//  Copyright © 2019 zed.wang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class WKJAlertAction;
@interface WKJAlert : UIView

@property (nonatomic, strong) UIColor *maskColor;
@property (nonatomic, strong) UIColor *lineColor;

@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, assign) NSTextAlignment titleTextAlignment;

@property (nonatomic, strong) UIColor *contentColor;
@property (nonatomic, strong) UIFont *contentFont;
@property (nonatomic, assign) NSTextAlignment contentTextAlignment;

@property (nonatomic, strong) UIFont *confirmActionTitleFont;
@property (nonatomic, strong) UIColor *confirmActionTitleColor;

@property (nonatomic, strong) UIFont *cancleActionTitleFont;
@property (nonatomic, strong) UIColor *cancleActionTitleColor;

+ (void)showWithTitle:(nullable NSString *)title
               cancel:(nullable WKJAlertAction *)cancel
              confirm:(nullable WKJAlertAction *)confirm;

+ (void)showWithContent:(nullable NSString *)content
                 cancel:(nullable WKJAlertAction *)cancel
                confirm:(nullable WKJAlertAction *)confirm;

+ (void)showWithTitle:(nullable NSString *)title
              content:(nullable NSString *)content
               cancel:(nullable WKJAlertAction *)cancel
              confirm:(nullable WKJAlertAction *)confirm;

+ (void)showWithImage:(nullable UIImage *)image
                title:(nullable NSString *)title
              content:(nullable NSString *)content
               cancel:(nullable WKJAlertAction *)cancel
              confirm:(nullable WKJAlertAction *)confirm;

+ (void)showWithCustomView:(UIView *)customView
                    cancel:(nullable WKJAlertAction *)cancel
                   confirm:(nullable WKJAlertAction *)confirm;

+ (void)hide;

+ (void)hideWithComplete:(nullable void(^)(void))complete;

@end

typedef void(^WKJAlertActionHandler)(void);

@interface WKJAlertAction : UIButton

+ (instancetype)actionWithTitle:(NSString *)title handler:(nullable WKJAlertActionHandler)handler;

+ (instancetype)actionWithTitle:(NSString *)title autoHide:(BOOL)autoHide handler:(nullable WKJAlertActionHandler)handler;

@end

NS_ASSUME_NONNULL_END
