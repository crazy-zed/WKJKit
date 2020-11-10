//
//  WKJBaseRequest.h
//  WKJKit
//
//  Created by 王恺靖 on 2019/3/13.
//  Copyright © 2019 wkj. All rights reserved.
//

#import "WKJRequestProtocol.h"

@class WKJBaseRequest;

typedef void(^WKJBaseRequestProgressBlock)(NSProgress *progress);
typedef void(^WKJBaseRequestCompleteBlock)(WKJBaseRequest *request);

@interface WKJBaseRequest : NSObject <WKJRequestProtocol, WKJRequestLifeCycle>

/// 请求任务，在发起请求前该值为nil
@property (nonatomic, strong, readonly) NSURLSessionTask *requestTask;

/// 完整请求头，在发起请求前该值为nil
@property (nonatomic, strong, readonly) NSDictionary *allRequestHeader;

/// 完整请求参数，在发起请求前该值为nil
@property (nonatomic, strong, readonly) NSDictionary *allParams;

/// 请求开始时间 (ms)
@property (nonatomic, assign, readonly) NSInteger startTime;

/// 请求结束时间 (ms)
@property (nonatomic, assign, readonly) NSInteger endTime;

/// 请求总耗时 (ms)
@property (nonatomic, assign, readonly) NSInteger duration;

/// 完整响应信息
@property (nonatomic, strong) NSHTTPURLResponse *URLResponse;

/// 响应头
@property (nonatomic, strong, readonly) NSDictionary *responseHeader;

/// 响应数据
@property (nonatomic, strong, readonly) id responseObject;

/// HTTP响应码
@property (nonatomic, readonly) NSInteger responseCode;

/// 请求失败错误信息
@property (nonatomic, strong, readonly) NSError *error;

/**
 *  快捷初始化方法，根据请求参数创建请求对象
 *  @param params 请求入参
 *  @return 请求对象
 */
+ (instancetype)requestWithParams:(NSDictionary *)params;

/**
 *  快捷初始化方法，根据请求参数创建请求对象
 *  @param params 请求入参
 *  @return 请求对象
 */
- (instancetype)initWithParams:(NSDictionary *)params;

/**
 *  发起请求
 *  @param success 成功回调
 *  @param fail 失败回调
 */
- (void)startBaseRequest:(WKJBaseRequestCompleteBlock)success
                    fail:(WKJBaseRequestCompleteBlock)fail;

/**
 *  发起请求
 *  @param progress 进度回调（下载为下载进度，上传为上传进度）
 *  @param success 成功回调
 *  @param fail 失败回调
 */
- (void)startBaseRequest:(WKJBaseRequestProgressBlock)progress
                 success:(WKJBaseRequestCompleteBlock)success
                    fail:(WKJBaseRequestCompleteBlock)fail;

/**
 *  暂停请求
 */
- (void)suspend;

/**
 *  恢复请求
 */
- (void)resume;

/**
 *  取消请求，会走fail回调
 */
- (void)cancel;

@end
