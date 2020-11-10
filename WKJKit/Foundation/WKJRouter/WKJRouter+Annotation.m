//
//  WKJRouter+Annotation.m
//  WKJVideo
//
//  Created by 王恺靖 on 2020/4/9.
//  Copyright © 2020 wkj. All rights reserved.
//

#import "WKJRouter+Annotation.h"
#import "WKJCommonDefine.h"
#import "NSObject+WKJKit.h"
#import "NSInvocation+WKJKit.h"
#import "UIViewController+WKJKit.h"

#include <dlfcn.h>
#include <mach-o/getsect.h>
#include <mach-o/loader.h>
#include <mach-o/dyld.h>
#include <mach-o/ldsyms.h>

#ifndef __LP64__
typedef uint32_t MemoryType;
#else
typedef uint64_t MemoryType;
#endif

static NSArray<NSString *>* reaadSectionData(const void *addr, char *sectionName) {
    Dl_info info;
    dladdr(addr, &info);
    unsigned long size = 0;
    
#ifndef __LP64__
    const struct mach_header *mhp = (const struct mach_header *)info.dli_fbase;
    MemoryType *memory = (MemoryType *)getsectiondata(mhp, SEG_DATA, sectionName, &size);
#else
    const struct mach_header_64 *mhp64 = (const struct mach_header_64 *)info.dli_fbase;
    MemoryType *memory = (MemoryType*)getsectiondata(mhp64, SEG_DATA, sectionName, &size);
#endif
    long counter = size/ sizeof(void *);
    NSMutableArray *dataAry = [[NSMutableArray alloc] init];
    
    for (int idx = 0; idx < counter; ++idx) {
        NSString *dataStr = [NSString stringWithUTF8String:(char *)memory[idx]];
        if (!dataStr.length) continue;
        [dataAry addObject:dataStr];
    }
    return [dataAry copy];
}

static NSString * const kWKJOpenVCStoryboardName = @"sb_name";
static NSString * const kWKJOpenVCCMD = @"cmd";

@implementation WKJRouter (Annotation)

static NSString *baseHost;

+ (void)registPathAnnotationsWithHost:(NSString *)host
{
    baseHost = host;
    const void *addr = (__bridge void *)[[UIApplication sharedApplication].delegate class];
    
    // 注册Controller
    NSArray<NSString *> *vcMappers = reaadSectionData(addr, WKJROUTER_SECTION_CONTROLLER);
    for (NSString *mapStr in vcMappers) {
        NSArray<NSString *> *components = [mapStr componentsSeparatedByString:@":"];
        [self registController:NSClassFromString(components.lastObject) storyBoard:nil path:components.firstObject];
    }
    
    // 注册StoryBoard Controller
    NSArray<NSString *> *sbVCMappers = reaadSectionData(addr, WKJROUTER_SECTION_SB_CONTROLLER);
    for (NSString *mapStr in sbVCMappers) {
        NSArray<NSString *> *components = [mapStr componentsSeparatedByString:@":"];
        if (components.count != 3) continue;
        [self registController:NSClassFromString(components.lastObject) storyBoard:components[1] path:components.firstObject];
    }
    
    // 注册Method
    NSArray<NSString *> *selMappers = reaadSectionData(addr, WKJROUTER_SECTION_METHOD);
    for (NSString *mapStr in selMappers) {
        NSArray<NSString *> *components = [mapStr componentsSeparatedByString:@":"];
        if (components.count != 3) continue;
        
        NSString *selector = [components[1] hasSuffix:@":"] ? components[1] : NSFormatString(@"%@:", components[1]);
        [self registSelector:NSSelectorFromString(selector) targetClass:NSClassFromString(components.lastObject) path:components.firstObject ];
    }
}

+ (void)registController:(Class)vcClass storyBoard:(NSString *)storyboard path:(NSString *)path
{
    if (vcClass == NULL) return;
    
    NSString *url = [self getURLStringWithPath:path];
    [WKJRouter registerURLString:url toHandler:^id(WKJRouterInfo *router) {
        id vcObject;
        if (!storyboard.length) {
            vcObject = [[vcClass alloc] init];
        } else {
            vcObject = [UIViewController wkj_viewControllerWithStoryboard:storyboard identifier:NSStringFromClass(vcClass)];
        }
        
        if (!vcObject) return nil;
        if (![vcObject isKindOfClass:UIViewController.class]) return nil;
        
        UIViewController *vc = (UIViewController *)vcObject;
        [self setupVC:vc router:router];
        [self jumpToVC:vc cmd:[router.params[kWKJOpenVCCMD] integerValue]];
        return vc;
    }];
}

+ (void)registSelector:(SEL)sel targetClass:(Class)targetClass path:(NSString *)path
{
    if (sel == NULL) return;
    if (targetClass == NULL) return;
    
    NSString *url = [self getURLStringWithPath:path];
    [WKJRouter registerURLString:url toHandler:^id(WKJRouterInfo *router) {
        // 验证sel合法性
        NSMethodSignature *sign = [targetClass methodSignatureForSelector:sel];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sign];
        if (invocation.wkj_arguments.count != 1) return nil;
        if (![[invocation wkj_argumentAtIndex:2] isKindOfClass:WKJRouterInfo.class]) return nil;
        
        [invocation setArgument:&router atIndex:2];
        @autoreleasepool {
            if ([targetClass respondsToSelector:sel]) {
                [invocation invokeWithTarget:targetClass]; return nil;
            }
            
            if ([targetClass instancesRespondToSelector:sel]) {
                [invocation invokeWithTarget:[targetClass new]]; return nil;
            }
        }
        return nil;
    }];
}

+ (id)openPath:(NSString *)path
{
    return [self openPath:path hanlder:nil];
}

+ (id)openPath:(NSString *)path hanlder:(WKJRouterOpenHandler)hanlder
{
    return [self openPath:path withParams:nil hanlder:hanlder];
}

+ (id)openPath:(NSString *)path withParams:(NSDictionary *)params hanlder:(WKJRouterOpenHandler)hanlder
{
    NSString *url = [self getURLStringWithPath:path];
    return [self openURLString:url withParams:params hanlder:hanlder];
}

+ (id)openVCPath:(NSString *)path cmd:(WKJRouteOpenVCCMD)cmd
{
    return [self openVCPath:path cmd:cmd hanlder:nil];
}

+ (id)openVCPath:(NSString *)path cmd:(WKJRouteOpenVCCMD)cmd hanlder:(WKJRouterOpenHandler)hanlder
{
    return [self openVCPath:path cmd:cmd withParams:nil hanlder:hanlder];
}

+ (id)openVCPath:(NSString *)path cmd:(WKJRouteOpenVCCMD)cmd withParams:(NSDictionary *)params hanlder:(WKJRouterOpenHandler)hanlder
{
    NSString *url = [self getURLStringWithPath:path];
    NSMutableDictionary *vcParams = params ? params.mutableCopy : @{}.mutableCopy;
    vcParams[kWKJOpenVCCMD] = @(cmd);
    return [self openURLString:url withParams:vcParams hanlder:hanlder];
}

#pragma mark - Private
+ (NSString *)getURLStringWithPath:(NSString *)path
{
    if ([baseHost hasSuffix:@"/"]) {
        baseHost = [baseHost substringToIndex:baseHost.length - 1];
    }
    
    if ([path hasPrefix:@"/"]) {
        path = [path substringFromIndex:1];
    }
    
    return NSFormatString(@"%@/%@", baseHost, path);
}

+ (NSString *)getClassNameWithSectionData:(NSString *)sectionData
{
    NSString *className = [sectionData componentsSeparatedByString:@"/"].lastObject;
    className = [className stringByReplacingOccurrencesOfString:@".h" withString:@""];
    className = [className stringByReplacingOccurrencesOfString:@".m" withString:@""];
    return className;
}

+ (void)setupVC:(UIViewController *)vc router:(WKJRouterInfo *)router
{
    if (!router.params.allKeys.count) return;
    
    for (NSString *property in vc.wkj_codingProperties) {
        if ([router.params.allKeys containsObject:property]) {
            [vc setValue:router.params[property] forKey:property];
        }
    }
}

+ (void)jumpToVC:(UIViewController *)vc cmd:(WKJRouteOpenVCCMD)cmd
{
    if (cmd == WKJRouteOpenCMDNone) return;
    
    UIViewController *topVC = [UIViewController wkj_visibleVC];
    UINavigationController *nav = topVC.navigationController;
    
    switch (cmd) {
        case WKJRouteOpenCMDPush:
            [nav pushViewController:vc animated:YES];
            break;
            
        case WKJRouteOpenCMDPresent: {
            [topVC presentViewController:vc animated:YES completion:nil];
        }
            break;
            
        case WKJRouteOpenCMDPresentInNav: {
            UINavigationController *newNav = [[UINavigationController alloc] initWithRootViewController:vc];
            [topVC presentViewController:newNav animated:YES completion:nil];
        }
            break;
            
        default:
            break;
    }
}

@end

