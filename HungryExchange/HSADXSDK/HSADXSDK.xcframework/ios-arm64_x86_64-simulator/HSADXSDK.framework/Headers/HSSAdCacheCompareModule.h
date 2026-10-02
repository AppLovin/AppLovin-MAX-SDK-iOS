//
//  HSSAdCacheCompareModule.h
//  HSADXSDK
//
//  Created by 张松
//

#import <Foundation/Foundation.h>

@class HSSCreativeItemModel;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, HSSAdCacheBucketType) {
    HSSAdCacheBucketTypeLegacy = 0,/// 旧桶
    HSSAdCacheBucketTypeV2 = 1, /// 新桶
};

/// 多缓存比价模块主入口
/// 处理原始 responseObject，返回可构建 HSSAdsModel 的 dict（仅替换 creatives，其余保留）
@interface HSSAdCacheCompareModule : NSObject

+ (instancetype)sharedInstance;

/// 处理广告请求结果，执行比价与缓存逻辑
/// @param placementId  广告位 id
/// @param responseObject 服务端原始返回，请求失败时传 nil
/// @param adType       广告类型字符串（如 @"1" 插屏、@"2" 激励）
/// @param isDirect     YES=直连（跨 pid 取全局最高价），NO=waterfall（仅取本 pid）
/// @return 处理后的 dict（creatives 已替换为 winner）；无法取到 winner 时返回 nil
- (NSDictionary * _Nullable)processWithPlacementId:(NSString *)placementId
                                    responseObject:(id _Nullable)responseObject
                                            adType:(NSString *)adType
                                          isDirect:(BOOL)isDirect
                                            bucket:(HSSAdCacheBucketType)bucket;

/// 同步降级，从mmkv缓存里取出已经准备好的素材
/// 若无 ready的素材，直接失败
/// @param completion 主线程回调；result=nil 表示无可用素材或缺 template
- (void)asyncFallbackForPlacementId:(NSString *)placementId
                             adType:(NSString *)adType
                           isDirect:(BOOL)isDirect
                      fallBackScene:(NSInteger)fallBackScene
                             bucket:(HSSAdCacheBucketType)bucket
                         completion:(void(^)(NSDictionary * _Nullable result))completion;

/// 展示成功后清理内存锁以及磁盘缓存
/// @param placementId  广告位 id
/// @param adType       广告类型字符串，与 process 时保持一致
- (void)notifyDisplaySuccessRemoveCache:(NSString *)placementId
                                 adType:(NSString *)adType
                                 reason:(NSString *)reason
                                 bucket:(HSSAdCacheBucketType)bucket;

/// server winner 不会在 process 阶段直接落盘；主流程 VAST 解析成功后首次写入磁盘成品池
- (void)writeBackWinnerVastResolvedIfNeededWithCreative:(HSSCreativeItemModel *)creative
                                               vastType:(NSString *)vastType
                                                 adType:(NSString *)adType
                                                 bucket:(HSSAdCacheBucketType)bucket;

@end

NS_ASSUME_NONNULL_END
