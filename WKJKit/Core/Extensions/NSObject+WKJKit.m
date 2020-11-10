//
//  NSObject+WKJKit.m
//  WKJKit
//
//  Created by zed.wang on 2019/7/8.
//  Copyright © 2019 zed.wang. All rights reserved.
//

#import "NSObject+WKJKit.h"
#import "WKJCommonDefine.h"
#import "NSInvocation+WKJKit.h"
#import "NSString+WKJKit.h"

#import <objc/message.h>
#import <CoreData/CoreData.h>

@interface WKJAspectInfo : NSObject<WKJAspectMeta>

@property (nonatomic, strong) Class clazz;
@property (nonatomic, copy) NSString *selectorName;
@property (nonatomic, copy) WKJAspectHandler handler;
@property (nonatomic, assign) WKJAspectPosition position;

@property (nonatomic, strong) NSInvocation *invocation;

@property (nonatomic, copy) NSString *forwardInvocationClassName;
@property (nonatomic, copy) NSString *replaceSelectorName;

+ (instancetype)aspectWithClass:(Class)clazz
                       selector:(SEL)selector
                        handler:(WKJAspectHandler)handler
                       posotion:(WKJAspectPosition)posotion;

- (void)invokeWithOriginalInvocation:(NSInvocation *)originalInvocation;

@end

@implementation WKJAspectInfo

@synthesize args = _args;

+ (instancetype)aspectWithClass:(Class)clazz
                       selector:(SEL)selector
                        handler:(WKJAspectHandler)handler
                       posotion:(WKJAspectPosition)posotion
{
    WKJAspectInfo *info = [[WKJAspectInfo alloc] init];
    info.selectorName = NSStringFromSelector(selector);
    info.handler = handler;
    info.position = posotion;
    
    info.forwardInvocationClassName = NSFormatString(@"WKJ_ForwardInvocation_%@", NSStringFromClass(clazz));
    info.replaceSelectorName = NSFormatString(@"wkj_replace_%@", info.selectorName);
    
    // 这里对hook类做了处理，如果能找到方法则直接赋值，否则取元类
    info.clazz = class_getInstanceMethod(clazz, selector) ? clazz : object_getClass(clazz);
    return info;
}

- (void)invokeWithOriginalInvocation:(NSInvocation *)originalInvocation
{
    originalInvocation.selector = NSSelectorFromString(self.replaceSelectorName);
    self.invocation = originalInvocation;
    
    Weakify(self);
    switch (self.position) {
        case WKJAspectPositionBefore: {
            !self.handler ?: self.handler(weak_self);
            [originalInvocation invoke];
        }
            break;
            
        case WKJAspectPositionInstead:
            !self.handler ?: self.handler(weak_self);
            break;
            
        case WKJAspectPositionAfter: {
            [originalInvocation invoke];
            !self.handler ?: self.handler(weak_self);
        }
            break;
    }
    
    // 执行完hook需释放当前invocation
    self.invocation = nil;
    _args = nil;
}

- (id)target
{
    return self.invocation.target;
}

- (NSArray *)args
{
    if (!_args) {
        _args = self.invocation.wkj_arguments;
    }
    return _args;
}

- (NSInvocation *)originalInvocation
{
    return self.invocation;
}

@end

@implementation NSObject (WKJKit)

#pragma mark - Public Methods
void doSynchronized(id context, dispatch_block_t block) {
    if (!context) {
        !block ?: block(); return;
    }
    
    dispatch_semaphore_wait([context wkj_lock], DISPATCH_TIME_FOREVER);
    !block ?: block();
    dispatch_semaphore_signal([context wkj_lock]);
}

+ (nullable NSError *)wkj_hookSelector:(SEL)selector
                          withPosition:(WKJAspectPosition)position
                            usingBlock:(WKJAspectHandler)block
{
    WKJAspectInfo *info = [WKJAspectInfo aspectWithClass:self selector:selector handler:block posotion:position];
    NSError *error = [self wkj_checkHookWithAspectInfo:info];
    if (error) return error;
    
    doSynchronized([NSObject class], ^{
        [self wkj_hookOrgMethodWithAspectInfo:info];
    });
    return nil;
}

+ (void)wkj_removeHookSelector:(SEL)selector
{
    NSString *aspectID = wkj_aspectID([self class], selector);
    doSynchronized([NSObject class], ^{
        WKJAspectInfo *info = wkj_classHookInfos([self class])[aspectID];
        if (!info) return;
        [self wkj_reduceOrgMethodWithAspectInfo:info];
    });
}

+ (NSArray<Class> *)wkj_getSubClasses
{
    static char kSubClassesAssociatedObject;
    NSArray<Class> *subClasses = objc_getAssociatedObject(self, &kSubClassesAssociatedObject);
    if (subClasses) return subClasses;
    
    NSMutableArray *resultArray = [NSMutableArray new];
    int classCount = objc_getClassList(NULL, 0);
    
    Class *classes = NULL;
    classes = (__unsafe_unretained Class *)malloc(sizeof(Class) *classCount);
    classCount = objc_getClassList(classes, classCount);
    
    for (int idx = 0; idx < classCount; idx++) {
        Class clazz = classes[idx];
        if (class_getSuperclass(clazz) == [self class]) {
            [resultArray addObject:clazz];
        }
    }
    
    free(classes);
    subClasses = resultArray.copy;
    objc_setAssociatedObject(self, &kSubClassesAssociatedObject, subClasses, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return subClasses;
}

- (id)wkj_performSelector:(SEL)selector withArguments:(id)firstArgument, ...
{
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:selector]];
    [invocation setTarget:self];
    [invocation setSelector:selector];
    
    if (firstArgument) {
        va_list valist;
        va_start(valist, firstArgument);
        [invocation setArgument:&firstArgument atIndex:2];
        
        id currentArgument;
        NSInteger index = 3;
        while ((currentArgument = va_arg(valist, id))) {
            [invocation setArgument:&currentArgument atIndex:index];
            index++;
        }
        va_end(valist);
    }
    
    __unsafe_unretained id returnValue;
    [invocation invoke];
    [invocation getReturnValue:&returnValue];
    return returnValue;
}

#pragma mark - Private Methods
static NSString * wkj_aspectID(Class clazz, SEL selector) {
    return NSFormatString(@"%@:%@", NSStringFromClass(clazz), NSStringFromSelector(selector)).wkj_MD5String;
}

static NSMutableDictionary<Class, NSMutableDictionary *> * wkj_hookInfos() {
    static char kAssociatedObjectHookInfos;
    NSMutableDictionary *hookInfos = objc_getAssociatedObject([NSObject class], &kAssociatedObjectHookInfos);
    if (!hookInfos) {
        hookInfos = @{}.mutableCopy;
        objc_setAssociatedObject([NSObject class], &kAssociatedObjectHookInfos, hookInfos, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return hookInfos;
}

static NSMutableDictionary<NSString *, WKJAspectInfo *> * wkj_classHookInfos(Class clazz) {
    Class saveClazz = clazz;
    if (class_isMetaClass(saveClazz)) {
        saveClazz = NSClassFromString(NSStringFromClass(saveClazz));
    }
    
    NSMutableDictionary *infos = wkj_hookInfos()[saveClazz];
    if (!infos) {
        infos = @{}.mutableCopy;
        wkj_hookInfos()[(id<NSCopying>)saveClazz] = infos;
    }
    
    return infos;
}

static BOOL wkj_hasHookedClass(Class clazz) {
    return wkj_classHookInfos(clazz).allKeys.count;
}

static void wkj_forwardInvocation(__unsafe_unretained id target, SEL selector, NSInvocation *invocation) {
    Class kClass = object_getClass(target);
    WKJAspectInfo *info;
    
    // 解决hook了父类，子类调用时不会触发handle的问题
    while (!info && kClass) {
        NSString *aspectID = wkj_aspectID(kClass, invocation.selector);
        info = wkj_classHookInfos(kClass)[aspectID];
        kClass = class_getSuperclass(kClass);
    }
    
    if (info) {
        [info invokeWithOriginalInvocation:invocation];
        return;
    }
    
    NSLog(@"未找到切面信息，将转发");
    return;
}

+ (NSError *)wkj_checkHookWithAspectInfo:(WKJAspectInfo *)aspectInfo
{
    static NSSet *selectorBlackList;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        selectorBlackList = [NSSet setWithObjects:@"retain", @"release", @"autorelease", @"forwardInvocation:", nil];
    });
    
    // step1：检查是否在hook黑名单
    if ([selectorBlackList containsObject:aspectInfo.selectorName]) {
        return NSErrorMake(NSFormatString(@"Selector %@ is in BlackList %@", aspectInfo.selectorName, selectorBlackList), 1000);
    }
    
    // step2：检查是否是dealloc错误位置
    if ([aspectInfo.selectorName isEqualToString:@"dealloc"] &&
        aspectInfo.position != WKJAspectPositionBefore) {
        return NSErrorMake(@"WKJAspectPositionBefore is the only valid position when hooking dealloc.", 1001);
    }
    
    // step3：压根没实现该方法
    SEL selector = NSSelectorFromString(aspectInfo.selectorName);
    if (![aspectInfo.clazz instancesRespondToSelector:selector]) {
        return NSErrorMake(NSFormatString(@"Unable to find selector -[%@ %@].", aspectInfo.clazz, aspectInfo.selectorName), 1002);
    }
    
    return nil;
}

+ (void)wkj_hookOrgMethodWithAspectInfo:(WKJAspectInfo *)aspectInfo
{
    SEL replaceSelector = NSSelectorFromString(aspectInfo.replaceSelectorName);
    SEL orgSelector = NSSelectorFromString(aspectInfo.selectorName);
    IMP orgIMP = class_getMethodImplementation(aspectInfo.clazz, orgSelector);
    
    Method orgMethod = class_getInstanceMethod(aspectInfo.clazz, orgSelector);
    const char *typeEncoding = method_getTypeEncoding(orgMethod);
    
    // 添加替换方法实现(保存替换后的原有实现)
    if (![aspectInfo.clazz instancesRespondToSelector:replaceSelector]) {
        class_addMethod(aspectInfo.clazz, replaceSelector, orgIMP, typeEncoding);
    }
    
    class_replaceMethod(aspectInfo.clazz, orgSelector, _objc_msgForward, typeEncoding);
    
    if (!wkj_hasHookedClass(aspectInfo.clazz)) {
        class_replaceMethod(aspectInfo.clazz, @selector(forwardInvocation:), (IMP)wkj_forwardInvocation, "v@:@");
    }
    
    NSString *aspectID = wkj_aspectID(aspectInfo.clazz, orgSelector);
    wkj_classHookInfos(aspectInfo.clazz)[aspectID] = aspectInfo;
}

+ (void)wkj_reduceOrgMethodWithAspectInfo:(WKJAspectInfo *)aspectInfo
{
    SEL replaceSelector = NSSelectorFromString(aspectInfo.replaceSelectorName);
    SEL orgSelector = NSSelectorFromString(aspectInfo.selectorName);
    IMP orgIMP = class_getMethodImplementation(aspectInfo.clazz, replaceSelector);
    Method orgMethod = class_getInstanceMethod(aspectInfo.clazz, orgSelector);
    const char *typeEncoding = method_getTypeEncoding(orgMethod);
    class_replaceMethod(aspectInfo.clazz, orgSelector, orgIMP, typeEncoding);
    
    if (wkj_classHookInfos(aspectInfo.clazz).allKeys.count == 1) {
        Method forwardMethod = class_getInstanceMethod(NSObject.class, @selector(forwardInvocation:));
        IMP forwardIMP = method_getImplementation(forwardMethod);
        class_replaceMethod(aspectInfo.clazz, @selector(forwardInvocation:), forwardIMP, "v@:@");
    }
    
    NSString *aspectID = wkj_aspectID(aspectInfo.clazz, orgSelector);
    [wkj_classHookInfos(aspectInfo.clazz) removeObjectForKey:aspectID];
}

- (dispatch_semaphore_t)wkj_lock
{
    static char kLockAssociatedObject;
    dispatch_semaphore_t lock = objc_getAssociatedObject(self, &kLockAssociatedObject);
    if (!lock) {
        lock = dispatch_semaphore_create(1);
        objc_setAssociatedObject(self, &kLockAssociatedObject, lock, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return lock;
}

@end

#pragma mark ******WKJKit_Coding******
@implementation NSObject (WKJKit_Coding)

#pragma mark - Public Methods
- (NSArray<NSString *> *)wkj_codingProperties
{
    NSArray<NSString *> *properties = objc_getAssociatedObject(self, @selector(wkj_codingProperties));
    if (properties) return properties;
    
    static NSSet<NSString *> *pp_proprities;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pp_proprities = [NSObject wkj_objectProtocolProperties];
    });
    
    NSMutableArray<NSString *> *temp = @[].mutableCopy;
    Class c = [self class];
    while (c && ![NSStringFromClass(c) hasPrefix:@"NS"]) {
        unsigned int count = 0;
        objc_property_t *copyProperties = class_copyPropertyList(c, &count);
        for (unsigned int i = 0; i < count; i++) {
            NSString *name = @(property_getName(copyProperties[i]));
            // 过滤掉`hash`, `superclass`, `description`, `debugDescription`
            if ([pp_proprities containsObject:name]) continue;
            [temp addObject:name];
        }
        free(copyProperties);
        c = class_getSuperclass(c);
    }
    
    properties = temp.copy;
    objc_setAssociatedObject(self, @selector(wkj_codingProperties), properties, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return properties;
}

- (id)wkj_copyWithZone:(nullable NSZone *)zone
{
    id obj = [[self.class allocWithZone:zone] init];
    [[self.class wkj_codingProperties] enumerateObjectsUsingBlock:^(NSString *propertyName, NSUInteger idx, BOOL * _Nonnull stop) {
        id value = [self valueForKey:propertyName];
        if (!value) return;
        [obj setValue:value forKey:propertyName];
    }];
    return obj;
}

- (void)wkj_encode:(NSCoder *)encoder
{
    [[self.class wkj_codingProperties] enumerateObjectsUsingBlock:^(NSString *propertyName, NSUInteger idx, BOOL * _Nonnull stop) {
        id value = [self valueForKey:propertyName];
        if (!value) return;
        [encoder encodeObject:value forKey:propertyName];
    }];
}

- (void)wkj_decode:(NSCoder *)decoder
{
    [[self.class wkj_codingProperties] enumerateObjectsUsingBlock:^(NSString *propertyName, NSUInteger idx, BOOL * _Nonnull stop) {
        id value = [decoder decodeObjectForKey:propertyName];
        if (!value) return;
        [self setValue:value forKey:propertyName];
    }];
}

#pragma mark - Private Methods
+ (NSSet<NSString *> *)wkj_objectProtocolProperties
{
    unsigned int count = 0;
    objc_property_t *propertyList = protocol_copyPropertyList(@protocol(NSObject), &count);
    NSMutableSet *properties = [NSMutableSet setWithCapacity:count];
    for (int i = 0; i < count; i++) {
        NSString *pp_Name = @(property_getName(propertyList[i]));
        if (pp_Name.length) {
            [properties addObject:pp_Name];
        }
    }
    free(propertyList);
    return [properties copy];
}

@end

#pragma mark ******WKJKit_KVO******
@interface WKJObserver : NSObject

@property (nonatomic, copy) NSString *path;
@property (nonatomic, assign) NSKeyValueObservingOptions options;

@property (nonatomic, copy) WKJKitKVOHandler block;

+ (instancetype)observerWithKeyPath:(NSString *)keyPath
                           options:(NSKeyValueObservingOptions)options
                             block:(WKJKitKVOHandler)block;

@end

@implementation WKJObserver

+ (instancetype)observerWithKeyPath:(NSString *)keyPath
                           options:(NSKeyValueObservingOptions)options
                             block:(WKJKitKVOHandler)block
{
    WKJObserver *handler = [WKJObserver new];
    handler.path = keyPath;
    handler.options = options;
    handler.block = block;
    return handler;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    BOOL isPrior = [[change objectForKey:NSKeyValueChangeNotificationIsPriorKey] boolValue];
    if (isPrior) return;
    
    NSKeyValueChange changeKind = [[change objectForKey:NSKeyValueChangeKindKey] integerValue];
    if (changeKind != NSKeyValueChangeSetting) return;
    
    id oldVal = [change objectForKey:NSKeyValueChangeOldKey];
    if (oldVal == [NSNull null]) oldVal = nil;
    
    id newVal = [change objectForKey:NSKeyValueChangeNewKey];
    if (newVal == [NSNull null]) newVal = nil;
    
    !self.block ?: self.block(keyPath, oldVal, newVal);
}

@end

@implementation NSObject (WKJKit_KVO)

- (NSArray<NSString *> *)wkj_getAllObserverPaths
{
    return [self wkj_observers].allKeys;
}

- (void)wkj_addObserverForKeyPath:(NSString *)path handler:(WKJKitKVOHandler)handler
{
    [self wkj_addObserverForKeyPaths:@[path] handler:handler];
}

- (void)wkj_addObserverForKeyPaths:(NSArray<NSString *> *)paths handler:(WKJKitKVOHandler)handler
{
    [paths enumerateObjectsUsingBlock:^(NSString * _Nonnull path, NSUInteger idx, BOOL * _Nonnull stop) {
        NSKeyValueObservingOptions ops = NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld;
        WKJObserver *obs = [WKJObserver observerWithKeyPath:path
                                                   options:ops
                                                     block:handler];
        
        if ([self wkj_observers][path]) {
            [self wkj_removeObserverForKeyPath:path];
        }
        
        [self wkj_observers][path] = obs;
        [self addObserver:obs forKeyPath:path options:obs.options context:NULL];
    }];
}

- (void)wkj_removeObserverForKeyPath:(NSString *)path
{
    WKJObserver *obs = [self wkj_observers][path];
    if (!obs) return;
    [[self wkj_observers] removeObjectForKey:path];
    [self removeObserver:obs forKeyPath:path];
}

- (void)wkj_removeObserverForKeyPaths:(NSArray<NSString *> *)paths
{
    [paths enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        WKJObserver *obs = [self wkj_observers][key];
        if (!obs) return;
        [[self wkj_observers] removeObjectForKey:key];
        @try {
            [self removeObserver:obs forKeyPath:key];
        } @catch (NSException *exception) { }
    }];
}

- (void)wkj_removeAllObservers
{
    [[self wkj_observers] enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, WKJObserver * _Nonnull obs, BOOL * _Nonnull stop) {
        [[self wkj_observers] removeObjectForKey:key];
        @try {
            [self removeObserver:obs forKeyPath:key];
        } @catch (NSException *exception) { }
    }];
}

#pragma mark - Private Methods
- (NSMutableDictionary<NSString *, WKJObserver *> *)wkj_observers
{
    static char kObserversAssociatedObject;
    NSMutableDictionary *observers = objc_getAssociatedObject(self, &kObserversAssociatedObject);
    if (!observers) {
        observers = @{}.mutableCopy;
        objc_setAssociatedObject(self, &kObserversAssociatedObject, observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return observers;
}

@end

#pragma mark ******WKJKit_KVC******
@implementation NSObject (WKJKit_KVC)

- (void)wkj_setValue:(id)value forKey:(NSString *)key
{
    PushIgnoreKVCException
    [self setValue:value forKey:key];
    PopIgnoreKVCException
}

- (id)wkj_valueForKey:(NSString *)key
{
    PushIgnoreKVCException
    id value = [self valueForKey:key];
    PopIgnoreKVCException
    return value;
}

@end

@implementation NSThread (WKJKit_KVC)

WKJBOOLPropertySynthesizer(wkj_shouldAllowUIKVC, setWkj_shouldAllowUIKVC)

@end

@interface NSException (WKJKit_KVC)

@end

@implementation NSException (WKJKit_KVC)

+ (void)load
{
    [self wkj_hookSelector:@selector(raise:format:) withPosition:WKJAspectPositionInstead usingBlock:^(id<WKJAspectMeta>  _Nonnull aspectMeta) {
        NSExceptionName raise = aspectMeta.args.firstObject;
        NSString *format = aspectMeta.args.lastObject;
        NSString *kvcErrorPre = @"Access to %@'s %@ ivar is prohibited";
        
        BOOL tag = NSThread.currentThread.wkj_shouldAllowUIKVC;
        if (tag && raise == NSGenericException && [format hasPrefix:kvcErrorPre]) {
            return;
        }
        else {
            [aspectMeta.originalInvocation invoke];
        }
    }];
}

@end
