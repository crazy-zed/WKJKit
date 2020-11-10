//
//  WKJRequestModel.h
//  WKJKit
//
//  Created by 王恺靖 on 2019/3/13.
//  Copyright © 2019 wkj. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

typedef NS_ENUM(NSUInteger, WKJRequestMethod) {
    WKJRequestMethodGET = 0,
    WKJRequestMethodPOST,
    WKJRequestMethodDELETE,
    WKJRequestMethodDownload     //自定义的方法，专门处理下载任务(其实是GET)
};

/**
 *  请求/响应 规定的数据格式
 *  - WKJRequestSourceTypeJSON: JSON数据类型
 *  - WKJRequestSourceTypeHTTP: Request中为表单形式，Respones中为NSData
 */
typedef NS_ENUM(NSInteger, WKJRequestSourceType) {
    WKJRequestSourceTypeJSON = 0,
    WKJRequestSourceTypeHTTP,
};

typedef void(^WKJFormDataBodyBlock)(id<AFMultipartFormData> formData);

@protocol WKJRequestLifeCycle <NSObject>

- (void)paramsWillLoad:(NSMutableDictionary *)params;

- (void)requestWillStart:(NSURLSessionTask *)task;

- (void)requestExecuting:(NSProgress *)progress;

- (void)requestComplete:(id)responseObject error:(NSError *)error;

@end

/**
 *  WKJBaseRequest对象会将该协议全部实现，给予默认值
 */
@protocol WKJRequestProtocol <NSObject>

/**
 *  返回一个基础请求URL地址，必须遵循URL规范
 *  设置该值后会覆盖WKJNetworkConfig中的baseURL
 *  例如：https://api.example.com
 */
- (NSString *)baseURL;

/**
 *  返回一个请求路径，不包含前置host
 */
- (NSString *)requestPath;

/**
 *  是否允许设置代理，默认YES（如果返回NO并设置了代理所有网络请求都会失败）
 */
- (BOOL)shouldProxy;

/**
 *  是否开启一个新的session进行请求，默认为NO
 */
- (BOOL)useNewSession;

/**
 *  返回一个处理文件上传的block
 */
- (WKJFormDataBodyBlock)formDataBodyBlock;

/**
 *  返回一个网络超时时间，默认15s
 */
- (NSInteger)timeoutSeconds;

/**
 *  响应队列，默认dispatch_get_main_queue
 */
- (dispatch_queue_t)responseQueue;

/**
 *  返回请求方法，默认WKJRequestMethodGET
 */
- (WKJRequestMethod)requestMethod;

/**
 *  返回请求参数数据类型，默认WKJRequestSourceTypeJSON
 */
- (WKJRequestSourceType)requestSourceType;

/**
 *  返回响应数据类型，默认WKJRequestSourceTypeJSON
 */
- (WKJRequestSourceType)responseSourceType;

/**
 *  返回请求参数
 */
- (NSDictionary *)requestParameters;

/**
 *  返回请求头信息，字典的Key/value对应Header的Key/value
 */
- (NSDictionary<NSString *, NSString *> *)requestHeader;

/**
 *  返回一个下载路径，仅在WKJRequestMethodDownload方法下有效
 */
- (NSString *)downloadFolderPath;

/**
 *  返回一个下载文件名称，仅在WKJRequestMethodDownload方法下有效
 */
- (NSString *)downloadFileName;

/**
 *  忽略一切WKJNetworkConfig中的内容，用于自定义请求，默认为NO
 */
- (BOOL)ignoreNetworkConfig;

@end
