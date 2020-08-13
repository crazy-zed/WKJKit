//
//  NSObject+WKJKit.h
//  WKJKit
//
//  Created by zed.wang on 2019/7/8.
//  Copyright © 2019 zed.wang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define WKJCopyingImplementation \
- (id)copyWithZone:(nullable NSZone *)zone \
{ \
    return [self wkj_copyWithZone:zone]; \
} \

#define WKJCodingImplementation \
- (id)initWithCoder:(NSCoder *)decoder \
{ \
    if (self = [super init]) { \
        [self wkj_decode:decoder]; \
    } \
    return self; \
} \
\
- (void)encodeWithCoder:(NSCoder *)encoder \
{ \
    [self wkj_encode:encoder]; \
}

typedef NS_ENUM(NSUInteger, WKJAspectPosition) {
    WKJAspectPositionAfter   = 0,
    WKJAspectPositionInstead,
    WKJAspectPositionBefore,
};

@protocol WKJAspectMeta <NSObject>

@property (nonatomic, unsafe_unretained, readonly) id target;
@property (nonatomic, strong, readonly) NSArray *args;
@property (nonatomic, strong, readonly) NSInvocation *originalInvocation;

@end

typedef void(^WKJAspectHandler)(id<WKJAspectMeta> aspectMeta);

@interface NSObject (WKJKit)

void doSynchronized(id context, dispatch_block_t block);

+ (nullable NSError *)wkj_hookSelector:(SEL)selector
                          withPosition:(WKJAspectPosition)position
                            usingBlock:(WKJAspectHandler)block;

+ (void)wkj_removeHookSelector:(SEL)selector;

@end

@interface NSObject (WKJKit_Coding)

/// 获取所有需要编码的属性名（包括父类，一直到NS类为止）
+ (NSArray<NSString *> *)wkj_codingProperties;

/// copy协议实现
- (id)wkj_copyWithZone:(nullable NSZone *)zone;

/// coding协议实现
- (void)wkj_encode:(NSCoder *)encoder;

/// coding协议实现
- (void)wkj_decode:(NSCoder *)decoder;

@end

@interface NSObject (WKJKit_KVC)

- (void)wkj_setValue:(id)value forKey:(NSString *)key;

- (id)wkj_valueForKey:(NSString *)key;

@end

@interface NSThread (WKJKit_KVC)

/// 是否允许在当前线程kvc访问私有属性（默认NO）
@property(nonatomic, assign) BOOL wkj_shouldAllowUIKVC;

@end

NS_ASSUME_NONNULL_END
