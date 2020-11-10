//
//  WKJRouter+Annotation.h
//  WKJVideo
//
//  Created by 王恺靖 on 2020/4/9.
//  Copyright © 2020 wkj. All rights reserved.
//

#import "WKJRouter.h"

#if __has_include("WKJRouter_Mappings.h")
#import "WKJRouter_Mappings.h"
#endif

#define WKJROUTER_SECTION_CONTROLLER        "vcs"
#define WKJROUTER_SECTION_SB_CONTROLLER     "sb_vcs"
#define WKJROUTER_SECTION_METHOD            "selectors"

#define WKJRouterController(routerPath,clazzName) \
__attribute__((used, section("__DATA,"WKJROUTER_SECTION_CONTROLLER""))) \
static char * const k_##clazzName##_Path = ""#routerPath":"#clazzName"";

#define WKJRouterStoryboardController(routerPath,sbName,clazzName) \
__attribute__((used, section("__DATA,"WKJROUTER_SECTION_SB_CONTROLLER""))) \
static char * const k_##clazzName##_Path = ""#routerPath":"#sbName":"#clazzName"";

#define WKJRouterSelector(routerPath,selName,clazzName) \
__attribute__((used, section("__DATA,"WKJROUTER_SECTION_METHOD""))) \
static char * const k_##clazzName##selName##_Method = ""#routerPath":"#selName":"#clazzName"";

typedef NS_ENUM(NSUInteger, WKJRouteOpenVCCMD) {
    WKJRouteOpenCMDNone,
    WKJRouteOpenCMDPush,
    WKJRouteOpenCMDPresent,
    WKJRouteOpenCMDPresentInNav,
};

@interface WKJRouter (Annotation)

+ (void)registPathAnnotationsWithHost:(NSString *)host;

+ (void)registController:(Class)vcClass storyBoard:(NSString *)storyboard path:(NSString *)path;

+ (void)registSelector:(SEL)sel targetClass:(Class)targetClass path:(NSString *)path;

+ (id)openPath:(NSString *)path;

+ (id)openPath:(NSString *)path hanlder:(WKJRouterOpenHandler)hanlder;

+ (id)openPath:(NSString *)path withParams:(NSDictionary *)params hanlder:(WKJRouterOpenHandler)hanlder;

+ (id)openVCPath:(NSString *)path cmd:(WKJRouteOpenVCCMD)cmd;

+ (id)openVCPath:(NSString *)path cmd:(WKJRouteOpenVCCMD)cmd hanlder:(WKJRouterOpenHandler)hanlder;

+ (id)openVCPath:(NSString *)path cmd:(WKJRouteOpenVCCMD)cmd withParams:(NSDictionary *)params hanlder:(WKJRouterOpenHandler)hanlder;

@end

