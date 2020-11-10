//
//  WKJBaseRequest.m
//  WKJKit
//
//  Created by 王恺靖 on 2019/3/13.
//  Copyright © 2019 wkj. All rights reserved.
//

#import "WKJBaseRequest.h"
#import "WKJNetworking.h"

@interface WKJBaseRequest ()

@property (nonatomic, strong) NSDictionary *params;

@property (nonatomic, copy) WKJBaseRequestProgressBlock progressBlock;

@property (nonatomic, copy) WKJBaseRequestCompleteBlock successBlock;

@property (nonatomic, copy) WKJBaseRequestCompleteBlock failBlock;

@end

@implementation WKJBaseRequest

+ (instancetype)requestWithParams:(NSDictionary *)params
{
    return [[self alloc] initWithParams:params];
}

- (instancetype)initWithParams:(NSDictionary *)params
{
    self = [super init];
    if (self) {
        self.params = params;
    }
    return self;
}

#pragma mark - Actions
- (void)startBaseRequest:(WKJBaseRequestCompleteBlock)success
                    fail:(WKJBaseRequestCompleteBlock)fail
{
    [self startBaseRequest:nil success:success fail:fail];
}

- (void)startBaseRequest:(WKJBaseRequestProgressBlock)progress
                 success:(WKJBaseRequestCompleteBlock)success
                    fail:(WKJBaseRequestCompleteBlock)fail
{
    
    self.progressBlock = progress;
    self.successBlock = success;
    self.failBlock = fail;
    [[WKJNetworking shareInstance] startRequest:self];
}

- (void)suspend
{
    [self.requestTask suspend];
}

- (void)resume
{
    [self.requestTask resume];
}

- (void)cancel
{
    [self.requestTask cancel];
}

#pragma mark - Request LifeCycle
- (void)paramsWillLoad:(NSMutableDictionary *)params
{
    _allParams = [params copy];
}

- (void)requestWillStart:(NSURLSessionTask *)task
{
    _requestTask = task;
    _startTime = [[NSDate date] timeIntervalSince1970] * 1000;
}

- (void)requestExecuting:(NSProgress *)progress
{
    !self.progressBlock ?: self.progressBlock(progress);
}

- (void)requestComplete:(id)responseObject error:(NSError *)error
{
    _responseObject = responseObject;
    _error = error;
    
    _endTime = [[NSDate date] timeIntervalSince1970] * 1000;
    _duration = self.endTime - self.startTime;
    
    @autoreleasepool {
        if (error) {
            !self.failBlock ?: self.failBlock(self);
        } else {
            !self.successBlock ?: self.successBlock(self);
        }
    }
    
    [self releaseBlocks];
}

#pragma mark - Getter
- (NSDictionary *)allRequestHeader
{
    return self.requestTask.currentRequest.allHTTPHeaderFields;
}

- (NSHTTPURLResponse *)URLResponse
{
    return (NSHTTPURLResponse *)self.requestTask.response;
}

- (NSDictionary *)responseHeader
{
    return self.URLResponse.allHeaderFields;
}

- (NSInteger)responseCode
{
    return self.error ? self.error.code : self.URLResponse.statusCode;
}

#pragma mark - Private
- (void)releaseBlocks
{
    self.progressBlock = nil;
    self.successBlock = nil;
    self.failBlock = nil;
}

#pragma mark - WKJRequestProtocol
- (NSString *)requestPath
{
    return @"";
}

- (NSString *)baseURL
{
    return @"";
}

- (NSString *)cdnURL
{
    return @"";
}

- (BOOL)useCDN
{
    return NO;
}

- (BOOL)shouldProxy
{
    return YES;
}

- (BOOL)useNewSession
{
    return NO;
}

- (WKJFormDataBodyBlock)formDataBodyBlock
{
    return nil;
}

- (NSDictionary *)requestParameters
{
    return self.params ?: @{};
}

- (NSDictionary<NSString *, NSString *> *)requestHeader
{
    return @{};
}

- (NSString *)downloadFolderPath
{
    NSString *root = NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory,NSUserDomainMask,YES)[0];
    return [root stringByAppendingPathComponent:@"download"];
}

- (NSString *)downloadFileName
{
    return @"";
}

- (NSInteger)timeoutSeconds
{
    return 15;
}

- (dispatch_queue_t)responseQueue
{
    return dispatch_get_main_queue();
}

- (WKJRequestMethod)requestMethod
{
    return WKJRequestMethodGET;
}

- (WKJRequestSourceType)requestSourceType
{
    return WKJRequestSourceTypeJSON;
}

- (WKJRequestSourceType)responseSourceType
{
    return WKJRequestSourceTypeJSON;
}

- (NSInteger)cacheSeconds
{
    return 0;
}

- (BOOL)ignoreNetworkConfig
{
    return NO;
}

- (BOOL)needsSign
{
    return NO;
}

@end
