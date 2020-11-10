//
//  WKJNetworking.m
//  WKJKit
//
//  Created by 王恺靖 on 2019/3/13.
//  Copyright © 2019 wkj. All rights reserved.
//

#import "WKJNetworking.h"
#import "WKJCommonDefine.h"
#import "WKJBaseRequest.h"

#import "NSObject+WKJKit.h"
#import "NSString+WKJKit.h"

#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif

@interface NSURLSessionTask (LXNetworking)

@property (nonatomic, copy, readonly) NSString *taskUUID;

@end

@implementation NSURLSessionTask (LXNetworking)

- (NSString *)taskUUID
{
    static char kTaskUUIDAssociatedObject;
    NSString *uuid = objc_getAssociatedObject(self, &kTaskUUIDAssociatedObject);
    if (!uuid.length) {
        int32_t randomNum = arc4random_uniform([[NSDate date] timeIntervalSince1970] * 1000);
        uuid = NSFormatString(@"%@%d", [NSString wkj_randomStringWithLenth:6].uppercaseString, randomNum);
        objc_setAssociatedObject(self, &kTaskUUIDAssociatedObject, uuid, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    return uuid;
}

@end

@interface WKJNetworking ()

@property (nonatomic, strong) AFHTTPSessionManager *manager;

@property (nonatomic, strong) NSMutableDictionary<NSString *, WKJBaseRequest *> *requests;

@property (nonatomic, strong) NSMutableDictionary *netstatusListenBlocks;

// readonly
@property (nonatomic, strong) WKJNetworkConfig *config;

@end

@implementation WKJNetworking

static WKJNetworking *network = nil;
static dispatch_once_t onceToken;

+ (instancetype)shareInstance
{
    dispatch_once(&onceToken, ^{
        network = [[self alloc] init];
        AFNetworkReachabilityManager *rm = [AFNetworkReachabilityManager sharedManager];
        [rm startMonitoring];
        
        [rm setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            doSynchronized(network.netstatusListenBlocks, ^{
                for (WKJNetworkStatusChangeBlock block in network.netstatusListenBlocks.allValues) {
                    PushIgnoreWarning(-Wenum-conversion)
                    !block ?: block(status);
                    PopIgnoreWarning
                }
            });
        }];
    });
    return network;
}

+ (void)releaseInstance
{
    onceToken = 0;
    network = nil;
}

+ (WKJNetworkingStatus)currentNetWorkStatus
{
    AFNetworkReachabilityManager *rm = [AFNetworkReachabilityManager sharedManager];
    PushIgnoreWarning(-Wenum-conversion)
    return rm.networkReachabilityStatus;
    PopIgnoreWarning
}

+ (void)listeningNetWorkStatusWithClass:(Class)clazz changed:(WKJNetworkStatusChangeBlock)changeBlock
{
    doSynchronized([WKJNetworking shareInstance].netstatusListenBlocks, ^{
        [[WKJNetworking shareInstance].netstatusListenBlocks setObject:[changeBlock copy] forKey:NSStringFromClass(clazz)];
    });
}

+ (void)removeListeningNetWorkStatusWithClass:(Class)clazz
{
    doSynchronized([WKJNetworking shareInstance].netstatusListenBlocks, ^{
        [[WKJNetworking shareInstance].netstatusListenBlocks removeObjectForKey:NSStringFromClass(clazz)];
    });
}

- (void)registNetworking:(WKJNetworkConfig *)config
{
    self.config = config;
}

- (void)startRequest:(WKJBaseRequest *)request
{
    NSError *requestError = nil;
    NSURLSessionTask *task = [self buildTaskWithRequest:request error:&requestError];
    [request requestWillStart:task];
    
    doSynchronized(self.requests, ^{
        [self.requests setObject:request forKey:task.taskUUID];
    });
    
    if (requestError) {
        [self handleRequestComplete:task responseObject:nil error:requestError];
        return;
    }
    
    [task resume];
}

- (void)cancelAllRequest
{
    doSynchronized(self.requests, ^{
        [self.requests enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, WKJBaseRequest * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj cancel];
        }];
    });
}

#pragma mark - 构建请求
- (NSString *)buildRequestURLWithRequest:(WKJBaseRequest *)request
{
    NSString *baseURL = [request baseURL].length || [request ignoreNetworkConfig] ? [request baseURL] : self.config.baseAPIURL;

    if (!baseURL.length) return nil;
    if ([baseURL hasSuffix:@"/"]) {
        baseURL = [baseURL substringToIndex:baseURL.length - 1];
    }
    
    NSString *path = [request requestPath];
    if (!path.length) {
        return [NSURL URLWithString:baseURL].absoluteString;
    }
    
    if ([path hasPrefix:@"/"]) {
        path = [path substringFromIndex:1];
    }

    return [baseURL stringByAppendingPathComponent:path];
}

- (BOOL)checkProxySetting
{
    NSDictionary *proxySettings = (__bridge NSDictionary *)(CFNetworkCopySystemProxySettings());
    NSArray *proxies = (__bridge NSArray *)(CFNetworkCopyProxiesForURL((__bridge CFURLRef _Nonnull)([NSURL URLWithString:@"https://www.baidu.com"]), (__bridge CFDictionaryRef _Nonnull)(proxySettings)));
    
    NSDictionary *settings = proxies[0];
    NSString *host = settings[@"kCFProxyHostNameKey"];
    if ([[settings objectForKey:(NSString *)kCFProxyTypeKey] isEqualToString:@"kCFProxyTypeNone"] ||
        [host isEqualToString:@"127.0.0.1"]) {
        return NO;
    }
    
    return YES;
}

- (AFHTTPRequestSerializer *)buildRequestSerializerWithRequest:(WKJBaseRequest *)request
{
    // setup serializer
    AFHTTPRequestSerializer *requestSerializer = nil;
    if ([request requestSourceType] == WKJRequestSourceTypeJSON) {
        requestSerializer = [AFJSONRequestSerializer serializer];
    }
    else {
        requestSerializer = [AFHTTPRequestSerializer serializer];
    }
    requestSerializer.timeoutInterval = [request timeoutSeconds];
    
    // setup headers
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [headers addEntriesFromDictionary:[request requestHeader]];
    [headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        [requestSerializer setValue:value forHTTPHeaderField:key];
    }];
    
    return requestSerializer;
}

- (NSURLSessionTask *)buildTaskWithRequest:(WKJBaseRequest *)request error:(NSError **)error
{
    AFHTTPSessionManager *manager = self.manager;
    if (request.useNewSession) {
        manager = [AFHTTPSessionManager manager];
    }
    manager.completionQueue = request.responseQueue;
    
    if (!request.shouldProxy && [self checkProxySetting]) {
        *error = [NSError errorWithDomain:@"" code:-1000 userInfo:@{NSLocalizedDescriptionKey:@"不支持代理网络访问"}];
        return [manager.session dataTaskWithURL:[NSURL URLWithString:@""]];
    }
    
    NSString *url = [self buildRequestURLWithRequest:request];
    if (!url) {
        *error = [NSError errorWithDomain:@"" code:-9999 userInfo:@{NSLocalizedDescriptionKey:@"请求地址不符合规范"}];
        return [manager.session dataTaskWithURL:[NSURL URLWithString:@""]];
    }
    
    // setup params
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:[request requestParameters]];
    [request paramsWillLoad:params];
    
    WKJFormDataBodyBlock bodyBlock = [request formDataBodyBlock];
    AFHTTPRequestSerializer *requestSerializer = [self buildRequestSerializerWithRequest:request];
    
    if (request.responseSourceType == WKJRequestSourceTypeJSON) {
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    else {
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    
    NSSet *contentTypes = [NSSet setWithArray:@[@"application/json",
                                                @"text/html",
                                                @"text/json",
                                                @"text/plain",
                                                @"text/javascript",
                                                @"text/xml",
                                                @"image/*"]];
    manager.responseSerializer.acceptableContentTypes = contentTypes;
    
    switch ([request requestMethod]) {
        case WKJRequestMethodPOST:
            return [self dataTaskWithHTTPMethod:@"POST" requestSerializer:requestSerializer sessionManager:manager URLString:url parameters:params formDataBodyBlock:bodyBlock error:error];
            
        case WKJRequestMethodDELETE:
            return [self dataTaskWithHTTPMethod:@"DELETE" requestSerializer:requestSerializer sessionManager:manager URLString:url parameters:params formDataBodyBlock:bodyBlock error:error];
            
        case WKJRequestMethodDownload:
            return [self downloadTaskWithSerializer:requestSerializer sessionManager:manager URLString:url parameters:params folderPath:request.downloadFolderPath fileName:request.downloadFileName error:error];
            
        default:
            return [self dataTaskWithHTTPMethod:@"GET" requestSerializer:requestSerializer sessionManager:manager URLString:url parameters:params formDataBodyBlock:bodyBlock error:error];
    }
}

- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                               requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                  sessionManager:(AFHTTPSessionManager *)sessionManager
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                               formDataBodyBlock:(WKJFormDataBodyBlock)formDataBodyBlock
                                           error:(NSError **)error
{
    NSMutableURLRequest *request = nil;
    if (formDataBodyBlock) {
        request = [requestSerializer multipartFormRequestWithMethod:method
                                                          URLString:URLString
                                                         parameters:parameters
                                          constructingBodyWithBlock:formDataBodyBlock
                                                              error:error];
    } else {
        request = [requestSerializer requestWithMethod:method
                                             URLString:URLString
                                            parameters:parameters
                                                 error:error];
    }
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [sessionManager dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        [self handleRequestProgress:dataTask progress:uploadProgress];
    } downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable _error) {
        [self handleRequestComplete:dataTask responseObject:responseObject error:_error];
    }];
    
    return dataTask;
}

- (NSURLSessionDownloadTask *)downloadTaskWithSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                          sessionManager:(AFHTTPSessionManager *)sessionManager
                                               URLString:(NSString *)URLString
                                              parameters:(id)parameters
                                              folderPath:(NSString *)folderPath
                                                fileName:(NSString *)fileName
                                                   error:(NSError **)error
{
    __block NSURLSessionDownloadTask *downloadTask = nil;
    __block NSString *name = fileName;
    NSMutableURLRequest *request = [requestSerializer requestWithMethod:@"GET" URLString:URLString parameters:parameters error:error];
    
    downloadTask = [sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        [self handleRequestProgress:downloadTask progress:downloadProgress];
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        NSString *downloadPath = folderPath;
        [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
        if (name.length) {
            name = [name stringByAppendingString:@"."];
            name = [name stringByAppendingString:[response.suggestedFilename componentsSeparatedByString:@"."].lastObject];
        }
        else {
            name = response.suggestedFilename;
        }
        
        downloadPath = [downloadPath stringByAppendingPathComponent:name];
        return [NSURL fileURLWithPath:downloadPath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable _error) {
        [self handleRequestComplete:downloadTask responseObject:filePath.path error:_error];
    }];
    
    return downloadTask;
}

#pragma mark - 处理请求回调
- (void)handleRequestProgress:(NSURLSessionTask *)task progress:(NSProgress *)progress
{
    __block WKJBaseRequest *request;
    doSynchronized(self.requests, ^{
        request = [self.requests objectForKey:task.taskUUID];
    });
    
    dispatch_async(MAIN_QUEUE, ^{
        [request requestExecuting:progress];
    });
}

- (void)handleRequestComplete:(NSURLSessionTask *)task responseObject:(id)responseObject error:(NSError *)error
{
    __block WKJBaseRequest *request;
    doSynchronized(self.requests, ^{
        request = [self.requests objectForKey:task.taskUUID];
        if (task.state == NSURLSessionTaskStateCompleted) {
            [self.requests removeObjectForKey:task.taskUUID];
        }
    });
    
    [request requestComplete:responseObject error:error];
}

#pragma mark - Lazy Load
- (AFHTTPSessionManager *)manager
{
    if (!_manager) {
        _manager = [AFHTTPSessionManager manager];
    }
    return _manager;
}

- (NSMutableDictionary<NSString *, WKJBaseRequest *> *)requests
{
    if (!_requests) {
        _requests = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return _requests;
}

- (NSMutableDictionary *)netstatusListenBlocks
{
    if (!_netstatusListenBlocks) {
        _netstatusListenBlocks = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return _netstatusListenBlocks;
}

@end


@implementation WKJNetworkConfig

+ (instancetype)defaultConfig
{
    return [[WKJNetworkConfig alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.baseAPIURL = @"";
        self.cdnUploadURL = @"";
        self.cdnDownloadURL = @"";
    }
    return self;
}

@end
