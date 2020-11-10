//
//  UIViewController+WKJKit.m
//  WKJKit
//
//  Created by Zed on 2020/10/13.
//

#import "UIViewController+WKJKit.h"
#import "WKJCommonDefine.h"

@implementation UIViewController (WKJKit)

+ (instancetype)wkj_rootViewControllerWithStoryboard:(NSString *)storyboard
{
    if (!storyboard.length) return nil;
    UIStoryboard *sb = [UIStoryboard storyboardWithName:storyboard bundle:nil];
    if (!sb) return nil;
    return [sb instantiateInitialViewController];
}

+ (instancetype)wkj_viewControllerWithStoryboard:(NSString *)storyboard identifier:(NSString *)identifier
{
    if (!storyboard.length || !identifier.length) return nil;
    UIStoryboard *sb = [UIStoryboard storyboardWithName:storyboard bundle:nil];
    if (!sb) return nil;
    return [sb instantiateViewControllerWithIdentifier:identifier];
}

+ (UIViewController *)wkj_visibleVC
{
    return [self wkj_findVisibleVCWithRootVC:MAIN_WINDOW.rootViewController];
}

+ (UIViewController *)wkj_findVisibleVCWithRootVC:(UIViewController *)rootVC
{
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)rootVC;
        return [self wkj_findVisibleVCWithRootVC:tabBarController.selectedViewController];
    }
    
    if ([rootVC isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController*)rootVC;
        return [self wkj_findVisibleVCWithRootVC:navigationController.visibleViewController];
    }
    
    if (rootVC.presentedViewController) {
        UIViewController *presentedViewController = rootVC.presentedViewController;
        return [self wkj_findVisibleVCWithRootVC:presentedViewController];
    }
    
    return rootVC;
}

@end
