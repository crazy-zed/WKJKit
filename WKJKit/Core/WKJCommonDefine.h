//
//  WKJCommonDefine.h
//  WKJKit
//
//  Created by zed.wang on 2019/7/6.
//  Copyright © 2019 zed.wang. All rights reserved.
//

#ifndef WKJCommonDefine_h
#define WKJCommonDefine_h

#import "WKJDeviceHelper.h"
#import <objc/runtime.h>

#pragma mark - ******************常用配置******************
// 屏幕尺寸
#define SCREEN_WIDTH        [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT       [UIScreen mainScreen].bounds.size.height
#define SCREEN_BOUNDS       [UIScreen mainScreen].bounds
#define SCREEN_SCALE        [UIScreen mainScreen].scale

#define SCREEN_ORIENTATION  UIApplication.sharedApplication.statusBarOrientation
#define DEVICE_ORIENTATION  [UIDevice currentDevice].orientation

#define IS_SCREEN_LANDSCAPE UIInterfaceOrientationIsLandscape(SCREEN_ORIENTATION)
#define IS_DEVICE_LANDSCAPE UIDeviceOrientationIsLandscape(DEVICE_ORIENTATION)

// 是否是全面屏（iPhone X及其以上，iPad pro等类无Home键屏幕）
#define IS_NO_HOME_SCREEN      [WKJDeviceHelper isNoHomeScreen]
#define MAIN_WINDOW            [WKJDeviceHelper getKeyWindow]

#define SAFE_AREA_MARGEN       [WKJDeviceHelper getDeviceSafeAreaInsets]
#define BOTTOM_MARGEN          (SAFE_AREA_MARGEN.bottom)

#define STATUS_BAR_HEIGHT      (UIApplication.sharedApplication.statusBarHidden ? 0 : UIApplication.sharedApplication.statusBarFrame.size.height)
#define NAVIGATION_BAR_HEIGHT  (IS_IPAD ? (IOS_VERSION_NUMBER >= 12.0 ? 50 : 44) : 44)

// 导航栏+状态栏
#define NAVIGATION_CONTENT_HEIGHT (STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT)

#pragma mark - *****************构造器*****************
// 字体
#define UIFontMake(fn,fs)        [UIFont fontWithName:fn size:(fs)]
#define UIFont(fontSize)         UIMakeFont(@"PingFangSC-Regular",fontSize)
#define UIBoldFont(fontSize)     UIMakeFont(@"PingFangSC-Semibold",fontSize)

// 颜色
#define UIRGBColor(r,g,b,a)      [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
#define UIHexColor(hexColor,a)   [UIColor colorWithHexString:hexColor alpha:(a)]

// 图片
#define UIImageMake(name)        [UIImage imageNamed:name]

// 字符串拼接
#define NSFormatString(fmt, ...) [NSString stringWithFormat:fmt, ##__VA_ARGS__]

// 错误
#define NSErrorMake(_domain, _code) [NSError errorWithDomain:_domain code:_code userInfo:nil]

#pragma mark - *****************系统相关*****************
// 设备相关
#define DEVICE_UUID      [WKJDeviceHelper getDeviceUUIDString]
#define DEVICE_NAME      [WKJDeviceHelper getDeviceNameString]
#define APP_VERSION      [WKJDeviceHelper getAppVersionString]
#define APP_BUILD        [WKJDeviceHelper getBuildVersionString]
#define APP_PACKAGE      [WKJDeviceHelper getAppPackageString]
#define BUILD_VERSION    [WKJDeviceHelper getBuildVersionString]
#define IOS_VERSION      [WKJDeviceHelper getSystemVersionString]

// 只获取第二级的版本号，例如 10.3.1 只会得到 10.3
#define IOS_VERSION_NUMBER   [IOS_VERSION doubleValue]

#define IS_IPHONE        [WKJDeviceHelper isIPhone]
#define IS_IPAD          [WKJDeviceHelper isIPad]
#define IS_SIMULATOR     [WKJDeviceHelper isSimulator]

// GCD操作相关
#define GLOBAL_QUEUE     dispatch_get_global_queue(0, 0)
#define MAIN_QUEUE       dispatch_get_main_queue()

#pragma mark - *****************其他*****************
// 强弱引用相关
#define Weakify(object)   __weak __typeof__(object) weak##_##object = object
#define Strongify(object) __strong __typeof__(object) object = weak##_##object

// 收发通知
#define PostNotifaction(notiName, infoDic) \
[[NSNotificationCenter defaultCenter] postNotificationName:notiName object:nil userInfo:(infoDic)]

#define HandleNotifaction(notiName, sel) \
[[NSNotificationCenter defaultCenter] addObserver:self selector:sel name:notiName object:nil]

// 警告处理
// warning名称列表参考：https://clang.llvm.org/docs/DiagnosticsReference.html
#define _ArgumentToString(macro) #macro
#define _ClangWarningConcat(warning_name) _ArgumentToString(clang diagnostic ignored warning_name)

#define PushIgnoreWarning(name)  _Pragma("clang diagnostic push") _Pragma(_ClangWarningConcat(#name))
#define PopIgnoreWarning         _Pragma("clang diagnostic pop")

#define PushIgnoreSelectorLeaksWarning PushIgnoreWarning(-Warc-performSelector-leaks)
#define PushIgnoreUndeclaredWarning    PushIgnoreWarning(-Wundeclared-selector)
#define PushIgnoreDeprecatedWarning    PushIgnoreWarning(-Wdeprecated-declarations)

#define PushIgnoreKVCException  NSThread.currentThread.wkj_shouldAllowUIKVC = YES;
#define PopIgnoreKVCException   NSThread.currentThread.wkj_shouldAllowUIKVC = NO;

// 版本判断（加这个是因为自动提示）
#define iOSAvailable(ver) @available(iOS ver, *)

#pragma mark - *****************Run Time*****************

#define _WKJTypeEncodingCompareCreater(_TypeName, _type) \
CG_INLINE BOOL is##_TypeName##TypeEncoding(const char *typeEncoding) {\
    return isEqualTypeEncoding(@encode(_type), typeEncoding);\
}\

CG_INLINE BOOL isEqualTypeEncoding(const char *typeEncoding_a, const char *typeEncoding_b) {
    return strncmp(typeEncoding_a, typeEncoding_b, strlen(typeEncoding_a)) == 0;
}

_WKJTypeEncodingCompareCreater(Char, char)
_WKJTypeEncodingCompareCreater(Int, int)
_WKJTypeEncodingCompareCreater(Short, short)
_WKJTypeEncodingCompareCreater(Long, long)
_WKJTypeEncodingCompareCreater(LongLong, long long)
_WKJTypeEncodingCompareCreater(NSInteger, NSInteger)
_WKJTypeEncodingCompareCreater(UnsignedChar, unsigned char)
_WKJTypeEncodingCompareCreater(UnsignedInt, unsigned int)
_WKJTypeEncodingCompareCreater(UnsignedShort, unsigned short)
_WKJTypeEncodingCompareCreater(UnsignedLong, unsigned long)
_WKJTypeEncodingCompareCreater(UnsignedLongLong, unsigned long long)
_WKJTypeEncodingCompareCreater(NSUInteger, NSUInteger)
_WKJTypeEncodingCompareCreater(Float, float)
_WKJTypeEncodingCompareCreater(Double, double)
_WKJTypeEncodingCompareCreater(CGFloat, CGFloat)
_WKJTypeEncodingCompareCreater(BOOL, BOOL)
_WKJTypeEncodingCompareCreater(Void, void)
_WKJTypeEncodingCompareCreater(Character, char *)
_WKJTypeEncodingCompareCreater(Object, id)
_WKJTypeEncodingCompareCreater(Class, Class)
_WKJTypeEncodingCompareCreater(Selector, SEL)

#pragma mark -
// 实现对象（引用类型）属性动态添加（Associated）
#define _WKJObjectPropertySynthesizer(_getterName, _setterName, _type, _policy) \
PushIgnoreWarning(-Wmismatched-parameter-types) \
PushIgnoreWarning(-Wmismatched-return-types) \
static char kAssociatedObjectKey_##_getterName;\
- (void)_setterName:(_type)_getterName {\
    objc_setAssociatedObject(self, &kAssociatedObjectKey_##_getterName, _getterName, OBJC_ASSOCIATION_##_policy##_NONATOMIC);\
}\
\
- (_type)_getterName {\
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_##_getterName);\
}\
PopIgnoreWarning

// 实现基础类型（值类型）属性动态添加（Associated）
#define _WKJValuePropertySynthesizer(_getterName, _setterName, _type, _typeValue) \
PushIgnoreWarning(-Wmismatched-parameter-types) \
PushIgnoreWarning(-Wmismatched-return-types) \
static char kAssociatedObjectKey_##_getterName;\
- (void)_setterName:(_type)_getterName {\
    objc_setAssociatedObject(self, &kAssociatedObjectKey_##_getterName, @(_getterName), OBJC_ASSOCIATION_RETAIN_NONATOMIC);\
}\
\
- (_type)_getterName {\
    NSNumber *value = (NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_##_getterName); \
    return [value _typeValue];\
}\
PopIgnoreWarning

#pragma mark -
#define WKJStrongPropertySynthesizer(_getterName, _setterName) _WKJObjectPropertySynthesizer(_getterName, _setterName, id, RETAIN)

#define WKJCopyPropertySynthesizer(_getterName, _setterName) _WKJObjectPropertySynthesizer(_getterName, _setterName, id, COPY)

#pragma mark -
#define WKJIntPropertySynthesizer(_getterName, _setterName) _WKJValuePropertySynthesizer(_getterName, _setterName, int, intValue)

#define WKJFloatPropertySynthesizer(_getterName, _setterName) _WKJValuePropertySynthesizer(_getterName, _setterName, float, floatValue)

#define WKJDoublePropertySynthesizer(_getterName, _setterName) _WKJValuePropertySynthesizer(_getterName, _setterName, double, doubleValue)

#define WKJBOOLPropertySynthesizer(_getterName, _setterName) _WKJValuePropertySynthesizer(_getterName, _setterName, BOOL, boolValue)

#define WKJIntegerPropertySynthesizer(_getterName, _setterName) _WKJValuePropertySynthesizer(_getterName, _setterName, NSInteger, integerValue)

#define WKJUIIntegerPropertySynthesizer(_getterName, _setterName) _WKJValuePropertySynthesizer(_getterName, _setterName, NSUInteger, unsignedIntegerValue)

#define WKJCGFloatPropertySynthesizer(_getterName, _setterName) _WKJValuePropertySynthesizer(_getterName, _setterName, CGFloat, doubleValue)

#define WKJCGPointPropertySynthesizer(_getterName, _setterName) _WKJValuePropertySynthesizer(_getterName, _setterName, CGPoint, CGPointValue)

#define WKJCGSizePropertySynthesizer(_getterName, _setterName) _WKJValuePropertySynthesizer(_getterName, _setterName, CGSize, CGSizeValue)

#define WKJCGRectPropertySynthesizer(_getterName, _setterName) _WKJValuePropertySynthesizer(_getterName, _setterName, CGRect, CGRectValue)

#define WKJInsetsPropertySynthesizer(_getterName, _setterName) _WKJValuePropertySynthesizer(_getterName, _setterName, UIEdgeInsets, UIEdgeInsetsValue)

#define WKJInsetsPropertySynthesizer(_getterName, _setterName) _WKJValuePropertySynthesizer(_getterName, _setterName, UIEdgeInsets, UIEdgeInsetsValue)

#define WKJUIOffsetPropertySynthesizer(_getterName, _setterName) _WKJValuePropertySynthesizer(_getterName, _setterName, UIOffset, UIOffsetValue)

#define WKJTransformPropertySynthesizer(_getterName, _setterName) _WKJValuePropertySynthesizer(_getterName, _setterName, CGAffineTransform, CGAffineTransformValue)

#endif /* WKJCommonDefine_h */
