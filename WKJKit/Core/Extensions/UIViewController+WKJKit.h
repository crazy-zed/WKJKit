//
//  UIViewController+WKJKit.h
//  WKJKit
//
//  Created by Zed on 2020/10/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (WKJKit)

+ (instancetype)wkj_rootViewControllerWithStoryboard:(NSString *)storyboard;

+ (instancetype)wkj_viewControllerWithStoryboard:(NSString *)storyboard identifier:(NSString *)identifier;

+ (UIViewController *)wkj_visibleVC;

+ (UIViewController *)wkj_findVisibleVCWithRootVC:(UIViewController *)rootVC;

@end

NS_ASSUME_NONNULL_END
