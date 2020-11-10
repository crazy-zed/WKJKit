//
//  WKJNetworking.h
//  WKJKit
//
//  Created by 王恺靖 on 2019/3/13.
//  Copyright © 2019 wkj. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WKJBaseRequest, WKJNetworkConfig;

typedef NS_ENUM(NSInteger, WKJNetworkingStatus) {
    WKJNetworkingStatusUnknown        = -1,  //未知网络
    WKJNetworkingStatusNotReachable   =  0,  //网络无连接
    WKJNetworkingStatusWWAN           =  1,  //2，3，4G网络
    WKJNetworkingStatusWiFi           =  2,  //WIFI网络
};

typedef void(^WKJNetworkStatusChangeBlock)(WKJNetworkingStatus status);

@interface WKJNetworking : NSObject

@property (nonatomic, strong, readonly) WKJNetworkConfig *config;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

+ (instancetype)shareInstance;
+ (void)releaseInstance;

+ (WKJNetworkingStatus)currentNetWorkStatus;

+ (void)listeningNetWorkStatusWithClass:(Class)clazz changed:(WKJNetworkStatusChangeBlock)changeBlock;

+ (void)removeListeningNetWorkStatusWithClass:(Class)clazz;

- (void)registNetworking:(WKJNetworkConfig *)config;

- (void)startRequest:(WKJBaseRequest *)request;

- (void)cancelAllRequest;

@end

@class AFSecurityPolicy;
@interface WKJNetworkConfig : NSObject

@property (nonatomic, copy) NSString *baseAPIURL;

@property (nonatomic, copy) NSString *cdnUploadURL;

@property (nonatomic, copy) NSString *cdnDownloadURL;

@property (nonatomic, strong) AFSecurityPolicy *securityPolicy;

+ (instancetype)defaultConfig;

@end
