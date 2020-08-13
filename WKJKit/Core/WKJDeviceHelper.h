//
//  WKJDeviceHelper.h
//  WKJKit
//
//  Created by zed.wang on 2019/7/6.
//  Copyright © 2019 zed.wangx. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKJDeviceHelper : NSObject

#pragma mark ---------- Device Info ----------
+ (NSString *)getAppPackageString;

+ (NSString *)getAppVersionString;

+ (NSString *)getBuildVersionString;

+ (NSString *)getSystemVersionString;

+ (NSString *)getDeviceUUIDString;

+ (NSString *)getDeviceNameString;

+ (NSString *)getDeviceLanguage;

+ (UIWindow *)getKeyWindow;

+ (UIEdgeInsets)getDeviceSafeAreaInsets;

+ (BOOL)isIPhone;
+ (BOOL)isIPad;
+ (BOOL)isSimulator;

/// 是否是全面屏（iPhone X及其以上，iPad pro等类无Home键屏幕）
+ (BOOL)isNoHomeScreen;

#pragma mark ---------- Device Opt ----------
+ (void)doLightFeedback;

@end

NS_ASSUME_NONNULL_END
