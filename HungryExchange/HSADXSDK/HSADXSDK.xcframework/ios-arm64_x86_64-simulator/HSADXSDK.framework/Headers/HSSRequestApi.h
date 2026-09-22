//
//  HSSRequestApi.h
//  HSADXSDK
//
//  Created by admin on 2024/11/25.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <HSADXSDK/HSSAdNetworking.h>


NS_ASSUME_NONNULL_BEGIN

@interface HSSRequestApi : NSObject

+ (void)requestConfigure:(NSDictionary *)params completionHandler:(HSSNetCompletionHandler)completionHandler;

+ (void)requestAds:(NSDictionary *)params completionHandler:(HSSNetCompletionHandler)completionHandler;

+ (void)requestAds:(NSDictionary *)params header:(NSDictionary *_Nullable)header completionHandler:(HSSNetCompletionHandler)completionHandler;

+ (void)requestWithUrl:(NSString *)url params:(NSDictionary *)params header:(NSDictionary *_Nullable)header fromPublic:(BOOL)fromPublic completionHandler:(HSSNetCompletionHandler)completionHandler;

/**
 下载图片
 @param url 图片下载地址
 */
+ (void)downLoadImage:(NSString *)url success:(void (^)(NSHTTPURLResponse *response, UIImage *image))success
             failure:(void (^)(NSHTTPURLResponse *response, NSError *error))failure;

/**
 下载文件
 @param url 文件下载地址
 */
+ (void)downLoadFile:(NSString *)url isOffline:(BOOL)isOffline success:(void (^)(NSURLResponse *response, NSURL *url))success
            failure:(void (^)(NSURLResponse *response, NSError *error))failure;

@end

/// 监测链接 GET、曝光/点击埋点、bid nurl 等与主请求流程无关，实现见 `HSSRequestApi+TrackReporting.m`
@interface HSSRequestApi (TrackReporting)

/**
 *@param urls 多个 url 请求
 */
+ (void)requestTrack:(NSArray *)urls;

/**
 *@param urls 多个 url 请求
 *@param eventName 事件名称
 *@param params 事件参数
 */
+ (void)requestTrack:(NSArray *)urls event:(NSString *_Nullable)eventName params:(NSDictionary *_Nullable)params;

/// 曝光类监测 GET + 埋点；重试次数与间隔由 `HSSInnerSettings.trackRetryDelays`（或 `hss_effectiveTrackRetryDelays` 回退到 impressionRetry / interval）决定，调用方无需传 maxRetry
+ (void)requestTrack:(NSArray *)urls event:(NSString *_Nullable)eventName source:(NSString *_Nullable)source params:(NSDictionary *_Nullable)params;

+ (void)requestClickTrack:(NSArray *)urls event:(NSString *_Nullable)eventName params:(NSDictionary *_Nullable)params;

+ (void)requestTrack:(NSArray *)urls event:(NSString *_Nullable)eventName isLocalAd:(BOOL)isLocalAd params:(NSDictionary *_Nullable)params;

/// deeplink跳转成功后上报
+ (void)reportDeeplinkRouterResultWithUrl:(NSString *)url;

/**
 上报 bid nurl/lurl，请求失败时自动存入 MMKV，下次启动重试
 @param urls nurl 或 lurl 数组
 */
+ (void)requestTrackBidUrls:(NSArray *)urls;

@end

NS_ASSUME_NONNULL_END
