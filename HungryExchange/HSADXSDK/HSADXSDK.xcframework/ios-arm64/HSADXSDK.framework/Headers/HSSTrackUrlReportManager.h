//
//  HSSTrackUrlReportManager.h
//  HSADXSDK
//
//  Created by biyingquan on 2025/7/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const HSSTrackImpInFlightKeyPrefix;

@interface HSSTrackUrlReportManager : NSObject

+ (instancetype)sharedInstance;

- (void)saveFailedAdURL:(NSString *)urlString forEvent:(NSString *)event;

- (void)reportPendingAdRequests;

- (void)reportPendingAdImpRequests:(NSString *)type;

- (void)reportPendingAdClickRequests;

- (void)saveFailedAdImpURLParams:(NSDictionary *)params forEvent:(NSString *)event;

/// 在 imp GET 进入延迟重试前写入 `adReportIMPMMKV`，同一 `stableKey` 覆盖更新，避免 URL+source 重复占多条
- (void)persistImpTrackInFlightParams:(NSDictionary *)params stableKey:(NSString *)stableKey;
- (void)removeImpTrackInFlightForStableKey:(NSString *)stableKey;

- (void)saveFailedAdClickURLParams:(NSDictionary *)params forEvent:(NSString *)event;

/// 存储用户杀死app的时候存储的数据，下次初始化sdk的时候上报
- (void)saveAppWillTerminateParams:(NSDictionary *)params forEvent:(NSString *)event;

/// 用户杀死app的时候存储的数据上报
- (void)reportTerminateParams;

/// 下载素材期间广告实例被释放的埋点上报
- (void)saveParamsDuringDownload:(NSDictionary *)params forEvent:(NSString *)event;

///上报
- (void)reportInstanceDeallocDuringDownload;

/// vast解析期间实例被释放
- (void)saveParamsDuringVastParse:(NSDictionary *)params forEvent:(NSString *)event;
- (void)reportInstanceDeallocDuringVastParse;

- (void)saveFailedDeepLinkReportURLParams:(NSDictionary *)params forEvent:(NSString *)event;
- (void)reportDeeplinkReportRequests;

/// 存储 bid nurl/lurl 请求失败的 URL，下次启动时重试
- (void)saveFailedBidURL:(NSString *)url;
/// 重试上次失败的 bid nurl/lurl
- (void)reportPendingBidURLs;
@end

NS_ASSUME_NONNULL_END
