//
//  WKJRouter.m
//  WKJKit
//
//  Created by 王恺靖 on 2019/3/18.
//  Copyright © 2019 wkj. All rights reserved.
//

#import "WKJRouter.h"
#import "WKJCommonDefine.h"

#import "NSObject+WKJKit.h"
#import "NSString+WKJKit.h"

#import <UIKit/UIKit.h>

@interface WKJRouter ()

@property (nonatomic, strong) NSMutableDictionary *routers;

@property (nonatomic, strong) dispatch_semaphore_t sign;

@end

static NSString * const WKJ_ROUTER_HANDLER_KEY = @"_handler";
static NSString * const WKJ_ROUTER_PATHOLDER_KEY = @"_placeholder";

// 这两个Key值后期做匹配算法优化的时候可能会用上
static NSString * const WKJ_ROUTER_SECTION_KEY = @"_section";
static NSString * const WKJ_ROUTER_INDEX_KEY = @"_index";

static NSString * const WKJ_ROUTER_PLACEHOLDER_PATH = @"~:place_holder";
static NSString * const WKJ_SPECIAL_CHARACTERS = @"/?&.";

@implementation WKJRouter

+ (instancetype)shared
{
    static WKJRouter *router = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        router = [[self alloc] init];
    });
    return router;
}

+ (NSDictionary *)routerDescription
{
    __block NSDictionary *desc = nil;
    doSynchronized([WKJRouter shared].routers, ^{
        desc = [[WKJRouter shared].routers copy];
    });
    return desc;
}

+ (void)registerURLString:(NSString *)URLString toHandler:(WKJRouterRegisterHandler)handler
{
    NSString *url = URLString.wkj_isURLEncodeString ? URLString : URLString.wkj_URLEncodeString;
    doSynchronized([WKJRouter shared].routers, ^{
        [[self shared] addURLString:url handler:handler];
    });
}

+ (BOOL)canOpenURLString:(NSString *)URLString
{
    __block BOOL canOpen = NO;
    NSString *url = URLString.wkj_isURLEncodeString ? URLString : URLString.wkj_URLEncodeString;
    doSynchronized([WKJRouter shared].routers, ^{
        canOpen = [[self shared] matchRouterWithURLString:url] ? YES : NO;
    });
    return canOpen;
}

+ (id)openURLString:(NSString *)URLString
{
    return [self openURLString:URLString handler:nil];
}

+ (id)openURLString:(NSString *)URLString handler:(WKJRouterOpenHandler)handler
{
    return [self openURLString:URLString withParams:nil hanlder:handler];
}

+ (id)openURLString:(NSString *)URLString withParams:(NSDictionary *)params hanlder:(WKJRouterOpenHandler)handler
{
    NSString *url = URLString.wkj_isURLEncodeString ? URLString : URLString.wkj_URLEncodeString;
    if (![self validateURLString:url]) {
        NSLog(@"\"%@\" 不符合URL规范，请检查修改", url);
        return nil;
    }
    
    __block NSDictionary *subRouter;
    doSynchronized([WKJRouter shared].routers, ^{
        subRouter = [[self shared] matchRouterWithURLString:url];
    });
    
    NSURL *URL = [NSURL URLWithString:url];
    if (!subRouter) {
        if ([[UIApplication sharedApplication] canOpenURL:URL]) {
            [[UIApplication sharedApplication] openURL:URL];
        } else {
            NSLog(@"\n-----WKJRouter Warnning-----\n\t%@\n未能匹配到该连接，未注册或不匹配", URLString);
        }
        return nil;
    }
    
    // 处理请求连接上拼接的参数，queryItems会自动decode
    NSArray *queryItems = [NSURLComponents componentsWithURL:URL resolvingAgainstBaseURL:NO].queryItems;
    NSMutableDictionary *whole = params ? params.mutableCopy : @{}.mutableCopy;
    for (NSURLQueryItem *item in queryItems) {
        whole[item.name] = item.value;
    }
    
    WKJRouterInfo *route = [WKJRouterInfo new];
    route.URLString = url;
    route.params = whole;
    route.openHandler = handler;
    route.pathHolderValues = subRouter[WKJ_ROUTER_PATHOLDER_KEY];
    
    WKJRouterRegisterHandler registHandler = subRouter[WKJ_ROUTER_HANDLER_KEY];
    if (!registHandler) return nil;
    
    id obj = registHandler(route);
    [obj setValue:route forKey:@"wkj_routerInfo"];
    return obj;
}

+ (void)cancelURLString:(NSString *)URLString
{
    doSynchronized([WKJRouter shared].routers, ^{
        [[self shared] removeURLString:URLString];
    });
}

+ (NSString *)formatURLString:(NSString *)URLString values:(NSArray<NSString *> *)values
{
    NSMutableArray *placeholders = [[NSMutableArray alloc] initWithCapacity:0];
    NSArray *comments = [URLString componentsSeparatedByString:@":"];

    for (NSString *comment in comments) {
        NSRange range = [self specialCharacterRangeWithString:comment];
        if (range.location == 0) continue;
        
        if (range.location != NSNotFound) {
            [placeholders addObject:[comment substringToIndex:range.location]];
        }
        else {
            [placeholders addObject:comment];
        }
    }
    [placeholders removeObjectAtIndex:0];
    
    NSAssert(placeholders.count == values.count, @"\"%@\"占位符与值数量不等，请检查URL或params", URLString);
    __block NSMutableString *result = [[NSMutableString alloc] initWithString:URLString];
    
    [placeholders enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *fullHolder = [NSString stringWithFormat:@":%@", obj];
        NSString *param = [values objectAtIndex:idx];
        [result replaceOccurrencesOfString:fullHolder withString:param options:NSCaseInsensitiveSearch range:NSMakeRange(0, result.length)];
    }];
    
    return [result copy];
}

#pragma mark - Private
+ (BOOL)validateURLString:(NSString *)URLString
{
    NSURL *url = [NSURL URLWithString:URLString];
    if (!url) {
        return NO;
    }
    return YES;
}

- (void)addURLString:(NSString *)URLString handler:(WKJRouterRegisterHandler)handler
{
    NSArray *pathComponents = [self pathComponentsWithURLString:URLString];
    if (!pathComponents.count) return;

    NSMutableDictionary *subRouters = self.routers;
    for (NSString *path in pathComponents) {    // 根据URL的scheme，host，path轮询创建或获取对应的子路由
        if ([path hasPrefix:@":"] && path.length == 1) {
            NSAssert(NO, @"\"%@\" 不符合URL规范，请检查修改", URLString);
        }
        // 如果是占位则使用共同path
        NSString *key = [path hasPrefix:@":"] ? WKJ_ROUTER_PLACEHOLDER_PATH : path;
        
        if (!subRouters[key]) {
            subRouters[key] = [[NSMutableDictionary alloc] initWithCapacity:0];
        }
        
        subRouters = subRouters[key];
    }
    
    subRouters[WKJ_ROUTER_HANDLER_KEY] = [handler copy];
}

- (void)removeURLString:(NSString *)URLString
{
    NSMutableArray *components = [NSMutableArray arrayWithArray:[self pathComponentsWithURLString:URLString]];
    if (!components.count) return;
    
    // 替换统一占位符
    [components enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj hasPrefix:@":"]) {
            [components replaceObjectAtIndex:idx withObject:WKJ_ROUTER_PLACEHOLDER_PATH];
        }
    }];
    
    // 找到该URL最后一层的key
    NSString *lastKey = components.lastObject;
    [components removeLastObject];
    // 去他对应的父级Dict
    NSString *keyPath = [components componentsJoinedByString:@"."];
    NSMutableDictionary *fatherRouter = [self.routers valueForKeyPath:keyPath];
    [fatherRouter removeObjectForKey:lastKey];
}

- (NSDictionary *)matchRouterWithURLString:(NSString *)URLString
{
    NSArray *components = [self pathComponentsWithURLString:URLString];
    NSMutableArray<NSString *> *placeholderValues = [NSMutableArray array];
    NSMutableDictionary *subRouter = self.routers;
    
    for (NSString *component in components) {
        // 排序是为了每层的key都可以按序排列，优先选择真正匹配到的最后再处理占位符情况
        NSArray *keys = [subRouter.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            return [obj1 compare:obj2];
        }];
        
        for (NSString *key in keys) {
            // key值是handler直接跳过
            if ([key isEqualToString:WKJ_ROUTER_HANDLER_KEY]) continue;
            // 真·匹配到
            if ([key isEqualToString:component]){
                subRouter = [subRouter objectForKey:key];
                break;
            }
            // 处理占位符URL情况
            if ([key isEqualToString:WKJ_ROUTER_PLACEHOLDER_PATH]) {
                subRouter = [subRouter objectForKey:key];
                [placeholderValues addObject:component];
                break;
            }
        }
    }
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[WKJ_ROUTER_PATHOLDER_KEY] = placeholderValues;
    if (subRouter[WKJ_ROUTER_HANDLER_KEY]) {
        info[WKJ_ROUTER_HANDLER_KEY] = [subRouter[WKJ_ROUTER_HANDLER_KEY] copy];
    }
    return [info copy];
}

- (NSArray *)pathComponentsWithURLString:(NSString *)URLString
{
    NSURL *URL = [NSURL URLWithString:URLString];
    NSMutableArray *components = [[NSMutableArray alloc] initWithCapacity:0];
    
    if (URL.scheme.length) {
        [components addObject:URL.scheme.wkj_URLDecodeString];
    }
    
    if (URL.host.length) {
        [components addObject:URL.host.wkj_URLDecodeString];
    }
    
    for (NSString *path in URL.pathComponents) {
        if ([path isEqualToString:@"/"]) continue;
        [components addObject:path.wkj_URLDecodeString];
    }
    
    return [components copy];
}

+ (NSRange)specialCharacterRangeWithString:(NSString *)str
{
    NSCharacterSet *specialSet = [NSCharacterSet characterSetWithCharactersInString:WKJ_SPECIAL_CHARACTERS];
    return [str rangeOfCharacterFromSet:specialSet];
}

#pragma mark - Lazy Load
- (NSMutableDictionary *)routers
{
    if (!_routers) {
        _routers = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return _routers;
}

- (dispatch_semaphore_t)sign
{
    if (!_sign) {
        _sign = dispatch_semaphore_create(1);
    }
    return _sign;
}

@end


@implementation WKJRouterInfo

- (NSString *)description
{
    NSMutableDictionary *desc = [NSMutableDictionary dictionary];
    desc[@"URLString"] = self.URLString;
    desc[@"Params"] = self.params;
    desc[@"PathHolderValues"] = self.pathHolderValues;
    desc[@"CompleteBlock"] = self.openHandler;
    return [NSString stringWithFormat:@"%@", desc];
}

@end


@implementation NSObject (WKJRouter)

WKJStrongPropertySynthesizer(wkj_routerInfo, setWkj_routerInfo)

@end
