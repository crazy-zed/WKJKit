//
//  WKJRouter.h
//  WKJKit
//
//  Created by 王恺靖 on 2019/3/18.
//  Copyright © 2019 wkj. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WKJRouterInfo;

/**
 *  注册相关操作
 *  @param router 要打开的线路信息
 */
typedef id (^WKJRouterRegisterHandler)(WKJRouterInfo *router);

/**
 *  打开完成的相关操作
 *  即A打开B，B做完某件事在通知并把结果发送给A
 *  @param openTag 完成回调标识，由于B可能做多件事都要传递给A，则可以使用openTag作为区分
 *  @param result 完成回调参数（使用Dictinary是因为避免B传入模型会造成耦合不符合路由设计初衷）
 */
typedef void (^WKJRouterOpenHandler)(NSString *openTag, NSDictionary *result);

@interface WKJRouter : NSObject

+ (instancetype)shared;

/**
 *  获取当前所有URL的注册信息
 *  @return 注册信息
 */
+ (NSDictionary *)routerDescription;

/**
 *  注册一条URL到路由
 *  @param URLString URL字符串
 *  @param handler 执行回调
 */
+ (void)registerURLString:(NSString *)URLString toHandler:(WKJRouterRegisterHandler)handler;

/**
 *  检查某个URL是否能被正常打开
 *  @param URLString URL字符串
 *  @return 是否能打开
 */
+ (BOOL)canOpenURLString:(NSString *)URLString;

/**
 *  打开某注册好的URL
 *  @param URLString URL字符串
 */
+ (id)openURLString:(NSString *)URLString;

/**
 *  打开某注册好的URL，并执行完成回调
 *  @param URLString URL字符串
 *  @param handler 打开完成回调
 */
+ (id)openURLString:(NSString *)URLString handler:(WKJRouterOpenHandler)handler;

/**
 *  打开某注册好的URL，并执行完成回调
 *  @param URLString URL字符串
 *  @param params 自定义参数
 *  @param handler 打开完成回调
 */
+ (id)openURLString:(NSString *)URLString withParams:(NSDictionary *)params hanlder:(WKJRouterOpenHandler)handler;

/**
 *  取消某注册好的URL
 *  @param URLString URL字符串
 */
+ (void)cancelURLString:(NSString *)URLString;

/**
 *  格式化占位符URL
 *  @param URLString URL字符串
 *  @param values 占位符代替的值
 */
+ (NSString *)formatURLString:(NSString *)URLString values:(NSArray<NSString *> *)values;

@end


@interface WKJRouterInfo : NSObject

/// 要打开的URL（会自动urlencode）
@property (nonatomic, copy) NSString *URLString;
/// 打开完毕回调Block
@property (nonatomic, copy) WKJRouterOpenHandler openHandler;
/// 打开入参（包括URL中的Query以及传入的Params）
@property (nonatomic, strong) NSDictionary *params;
/// PathComponents上的占位符value信息
@property (nonatomic, strong) NSArray<NSString *> *pathHolderValues;

@end

@interface NSObject (WKJRouter)

@property (nonatomic, strong) WKJRouterInfo *wkj_routerInfo;

@end
