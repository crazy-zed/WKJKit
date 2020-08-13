//
//  WKJDeviceHelper.m
//  WKJKit
//
//  Created by zed.wang on 2019/7/6.
//  Copyright © 2019 zed.wangx. All rights reserved.
//

#import "WKJDeviceHelper.h"
#import "WKJCommonDefine.h"

#import <sys/utsname.h>
#import <UICKeyChainStore/UICKeyChainStore.h>
#import <AudioToolbox/AudioToolbox.h>

@implementation WKJDeviceHelper

+ (NSString *)getAppPackageString
{
    static NSString *packageStr;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        packageStr = [NSBundle mainBundle].infoDictionary[@"CFBundleIdentifier"];
    });
    return packageStr;
}

+ (NSString *)getAppVersionString
{
    static NSString *versionStr;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        versionStr = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    });
    return versionStr;
}

+ (NSString *)getBuildVersionString
{
    static NSString *versionStr;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        versionStr = [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"];
    });
    return versionStr;
}

+ (NSString *)getSystemVersionString
{
    static NSString *versionStr;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        versionStr = [[UIDevice currentDevice] systemVersion];
    });
    return versionStr;
}

+ (NSString *)getDeviceUUIDString
{
    static NSString *uuid;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:[self getAppPackageString]];
        // 不进行iCloud同步
        keychain.accessibility = UICKeyChainStoreAccessibilityAlwaysThisDeviceOnly;
        uuid = keychain[@"WKJKit_UUID"];
        if (uuid.length) return;
        
        uuid = [[UIDevice currentDevice].identifierForVendor UUIDString];
        uuid = [uuid stringByReplacingOccurrencesOfString:@"-" withString:@""];
        [keychain setString:uuid forKey:@"WKJKit_UUID" error:nil];
    });
    return uuid;
}

+ (NSString *)getDeviceLanguage
{
    NSArray *languages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    return languages.firstObject ?: @"zh";
}

+ (NSString *)getDeviceNameString
{
    static NSString *name;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *deviceModel;
        if ([self isSimulator]) {
            // 模拟器通过环境变量获取
            deviceModel = NSFormatString(@"%s", getenv("SIMULATOR_MODEL_IDENTIFIER"));
        } else {
            struct utsname systemInfo;
            uname(&systemInfo);
            deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
        }
        
        if (!deviceModel.length) {
            name = @"Unknown Device"; return;
        }
        
        NSDictionary *mapping = @{
            // See https://www.theiphonewiki.com/wiki/Models
            @"iPhone1,1" : @"iPhone 1G",
            @"iPhone1,2" : @"iPhone 3G",
            @"iPhone2,1" : @"iPhone 3GS",
            @"iPhone3,1" : @"iPhone 4 (GSM)",
            @"iPhone3,2" : @"iPhone 4",
            @"iPhone3,3" : @"iPhone 4 (CDMA)",
            @"iPhone4,1" : @"iPhone 4S",
            @"iPhone5,1" : @"iPhone 5",
            @"iPhone5,2" : @"iPhone 5",
            @"iPhone5,3" : @"iPhone 5c",
            @"iPhone5,4" : @"iPhone 5c",
            @"iPhone6,1" : @"iPhone 5s",
            @"iPhone6,2" : @"iPhone 5s",
            @"iPhone7,1" : @"iPhone 6 Plus",
            @"iPhone7,2" : @"iPhone 6",
            @"iPhone8,1" : @"iPhone 6s",
            @"iPhone8,2" : @"iPhone 6s Plus",
            @"iPhone8,4" : @"iPhone SE",
            @"iPhone9,1" : @"iPhone 7",
            @"iPhone9,2" : @"iPhone 7 Plus",
            @"iPhone9,3" : @"iPhone 7",
            @"iPhone9,4" : @"iPhone 7 Plus",
            @"iPhone10,1" : @"iPhone 8",
            @"iPhone10,2" : @"iPhone 8 Plus",
            @"iPhone10,3" : @"iPhone X",
            @"iPhone10,4" : @"iPhone 8",
            @"iPhone10,5" : @"iPhone 8 Plus",
            @"iPhone10,6" : @"iPhone X",
            @"iPhone11,2" : @"iPhone XS",
            @"iPhone11,4" : @"iPhone XS Max",
            @"iPhone11,6" : @"iPhone XS Max CN",
            @"iPhone11,8" : @"iPhone XR",
            @"iPhone12,1" : @"iPhone 11",
            @"iPhone12,3" : @"iPhone 11 Pro",
            @"iPhone12,5" : @"iPhone 11 Pro Max",
            @"iPhone12,8" : @"iPhone SE (2nd generation)",

            @"iPad1,1" : @"iPad 1",
            @"iPad2,1" : @"iPad 2 (WiFi)",
            @"iPad2,2" : @"iPad 2 (GSM)",
            @"iPad2,3" : @"iPad 2 (CDMA)",
            @"iPad2,4" : @"iPad 2",
            @"iPad2,5" : @"iPad mini 1",
            @"iPad2,6" : @"iPad mini 1",
            @"iPad2,7" : @"iPad mini 1",
            @"iPad3,1" : @"iPad 3 (WiFi)",
            @"iPad3,2" : @"iPad 3 (4G)",
            @"iPad3,3" : @"iPad 3 (4G)",
            @"iPad3,4" : @"iPad 4",
            @"iPad3,5" : @"iPad 4",
            @"iPad3,6" : @"iPad 4",
            @"iPad4,1" : @"iPad Air",
            @"iPad4,2" : @"iPad Air",
            @"iPad4,3" : @"iPad Air",
            @"iPad4,4" : @"iPad mini 2",
            @"iPad4,5" : @"iPad mini 2",
            @"iPad4,6" : @"iPad mini 2",
            @"iPad4,7" : @"iPad mini 3",
            @"iPad4,8" : @"iPad mini 3",
            @"iPad4,9" : @"iPad mini 3",
            @"iPad5,1" : @"iPad mini 4",
            @"iPad5,2" : @"iPad mini 4",
            @"iPad5,3" : @"iPad Air 2",
            @"iPad5,4" : @"iPad Air 2",
            @"iPad6,3" : @"iPad Pro (9.7 inch)",
            @"iPad6,4" : @"iPad Pro (9.7 inch)",
            @"iPad6,7" : @"iPad Pro (12.9 inch)",
            @"iPad6,8" : @"iPad Pro (12.9 inch)",
            @"iPad6,11": @"iPad 5 (WiFi)",
            @"iPad6,12": @"iPad 5 (Cellular)",
            @"iPad7,1" : @"iPad Pro (12.9 inch, 2nd generation)",
            @"iPad7,2" : @"iPad Pro (12.9 inch, 2nd generation)",
            @"iPad7,3" : @"iPad Pro (10.5 inch)",
            @"iPad7,4" : @"iPad Pro (10.5 inch)",
            @"iPad7,5" : @"iPad 6 (WiFi)",
            @"iPad7,6" : @"iPad 6 (Cellular)",
            @"iPad7,11": @"iPad 7 (WiFi)",
            @"iPad7,12": @"iPad 7 (Cellular)",
            @"iPad8,1" : @"iPad Pro (11 inch)",
            @"iPad8,2" : @"iPad Pro (11 inch)",
            @"iPad8,3" : @"iPad Pro (11 inch)",
            @"iPad8,4" : @"iPad Pro (11 inch)",
            @"iPad8,5" : @"iPad Pro (12.9 inch, 3rd generation)",
            @"iPad8,6" : @"iPad Pro (12.9 inch, 3rd generation)",
            @"iPad8,7" : @"iPad Pro (12.9 inch, 3rd generation)",
            @"iPad8,8" : @"iPad Pro (12.9 inch, 3rd generation)",
            @"iPad8,9" : @"iPad Pro (11 inch, 2nd generation)",
            @"iPad8,10" : @"iPad Pro (11 inch, 2nd generation)",
            @"iPad8,11" : @"iPad Pro (12.9 inch, 4th generation)",
            @"iPad8,12" : @"iPad Pro (12.9 inch, 4th generation)",
            @"iPad11,1" : @"iPad mini (5th generation)",
            @"iPad11,2" : @"iPad mini (5th generation)",
            @"iPad11,3" : @"iPad Air (3rd generation)",
            @"iPad11,4" : @"iPad Air (3rd generation)",
            
            @"iPod1,1" : @"iPod touch 1",
            @"iPod2,1" : @"iPod touch 2",
            @"iPod3,1" : @"iPod touch 3",
            @"iPod4,1" : @"iPod touch 4",
            @"iPod5,1" : @"iPod touch 5",
            @"iPod7,1" : @"iPod touch 6",
            @"iPod9,1" : @"iPod touch 7",
            
            @"i386" : @"Simulator x86",
            @"x86_64" : @"Simulator x64",
            
            @"Watch1,1" : @"Apple Watch 38mm",
            @"Watch1,2" : @"Apple Watch 42mm",
            @"Watch2,3" : @"Apple Watch Series 2 38mm",
            @"Watch2,4" : @"Apple Watch Series 2 42mm",
            @"Watch2,6" : @"Apple Watch Series 1 38mm",
            @"Watch2,7" : @"Apple Watch Series 1 42mm",
            @"Watch3,1" : @"Apple Watch Series 3 38mm",
            @"Watch3,2" : @"Apple Watch Series 3 42mm",
            @"Watch3,3" : @"Apple Watch Series 3 38mm (LTE)",
            @"Watch3,4" : @"Apple Watch Series 3 42mm (LTE)",
            @"Watch4,1" : @"Apple Watch Series 4 40mm",
            @"Watch4,2" : @"Apple Watch Series 4 44mm",
            @"Watch4,3" : @"Apple Watch Series 4 40mm (LTE)",
            @"Watch4,4" : @"Apple Watch Series 4 44mm (LTE)",
            @"Watch5,1" : @"Apple Watch Series 5 40mm",
            @"Watch5,2" : @"Apple Watch Series 5 44mm",
            @"Watch5,3" : @"Apple Watch Series 5 40mm (LTE)",
            @"Watch5,4" : @"Apple Watch Series 5 44mm (LTE)",
            
            @"AudioAccessory1,1" : @"HomePod",
            @"AudioAccessory1,2" : @"HomePod",
            
            @"AirPods1,1" : @"AirPods (1st generation)",
            @"AirPods2,1" : @"AirPods (2nd generation)",

            @"AppleTV2,1" : @"Apple TV 2",
            @"AppleTV3,1" : @"Apple TV 3",
            @"AppleTV3,2" : @"Apple TV 3",
            @"AppleTV5,3" : @"Apple TV 4",
            @"AppleTV6,2" : @"Apple TV 4K",};
        name = mapping[deviceModel];
        if (!name.length) name = deviceModel;
        if ([self isSimulator]) name = [name stringByAppendingFormat:@" Simulator"];
    });
    return name;
}

+ (UIWindow *)getKeyWindow
{
    UIWindow *window;
    if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(window)]) {
        window = [UIApplication sharedApplication].delegate.window;
    }
    if (window) return window;
    
    window = [UIApplication sharedApplication].keyWindow;
    if (window) return window;
    
    return [UIApplication sharedApplication].windows.firstObject;
}

+ (UIEdgeInsets)getDeviceSafeAreaInsets
{
    if (![self isNoHomeScreen]) return UIEdgeInsetsZero;
    if ([self isIPad]) return UIEdgeInsetsMake(0, 0, 20, 0);
    
    switch (SCREEN_ORIENTATION) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationUnknown:
            return UIEdgeInsetsMake(44, 0, 34, 0);
            
        case UIInterfaceOrientationPortraitUpsideDown:
            return UIEdgeInsetsMake(34, 0, 44, 0);
            
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            return UIEdgeInsetsMake(0, 44, 21, 44);
    }
}

+ (BOOL)isIPhone
{
    static BOOL isIPhone;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *string = [[UIDevice currentDevice] model];
        isIPhone = [string rangeOfString:@"iPhone"].location != NSNotFound;
    });
    return isIPhone;
}

+ (BOOL)isIPad
{
    static BOOL isIPad;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isIPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    });
    return isIPad;
}

+ (BOOL)isSimulator
{
    static BOOL isSimulator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isSimulator = TARGET_OS_SIMULATOR == 1;
    });
    return isSimulator;
}

+ (BOOL)isNoHomeScreen
{
    static BOOL isNoHomeScreen = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (iOSAvailable(11.0)) {
            isNoHomeScreen = MAIN_WINDOW.safeAreaInsets.bottom > 0.0;
        }
    });
    return isNoHomeScreen;
}

+ (void)doLightFeedback
{
    if (iOSAvailable(10.0)) {
        UIImpactFeedbackGenerator *feed = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
        [feed impactOccurred];
    }
    else {
        AudioServicesPlaySystemSound(1519);
    }
}

@end
