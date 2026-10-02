//
//  HSSAdCacheStorage.h
//  HSADXSDK
//
//  Created by 张松
//

#import <Foundation/Foundation.h>
#import <HSADXSDK/HSSAdCacheCompareModule.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSAdCacheStorage : NSObject

+ (instancetype)sharedInstance;

/// 双层结构：adType → {pid → creatives}，写入指定 pid 的 creative 列表
- (void)saveCreativeDicts:(NSArray<NSDictionary *> *)dicts
              placementId:(NSString *)placementId
                   adType:(NSString *)adType
                   bucket:(HSSAdCacheBucketType)bucket;

- (void)appendCreativeDict:(NSDictionary *)dict
               placementId:(NSString *)placementId
                    adType:(NSString *)adType
                    bucket:(HSSAdCacheBucketType)bucket;

/// 读取指定 pid 下的 creative 列表（过期自动过滤）
- (NSArray<NSDictionary *> *)loadCreativeDictsForPlacementId:(NSString *)placementId
                                                       adType:(NSString *)adType
                                                       bucket:(HSSAdCacheBucketType)bucket;

/// 读取 adType 下所有 pid 的 creative 列表，用于跨 pid 比价（过期自动过滤）
- (NSDictionary<NSString *, NSArray<NSDictionary *> *> *)loadAllCreativeDictsForAdType:(NSString *)adType
                                                                                 bucket:(HSSAdCacheBucketType)bucket;

/// 按 hss_lock_token 精确删除一条 creative（跨 pid 查找）
- (void)removeCreativeWithToken:(NSString *)token
                         adType:(NSString *)adType
                         bucket:(HSSAdCacheBucketType)bucket;

/// 同上，reason 用于 QA 日志（如 展示成功、预解析失败）
- (void)removeCreativeWithToken:(NSString *)token
                         adType:(NSString *)adType
                         bucket:(HSSAdCacheBucketType)bucket
                         reason:(nullable NSString *)reason;

/// QA：当前 adType 下 MMKV 各 pid 条数与总条数摘要
- (NSString *)qaBriefCacheSnapshotForAdType:(NSString *)adType
                                     bucket:(HSSAdCacheBucketType)bucket;

/// 预解析成功后，将 resolved 数据合并到对应 token 的 creative dict（跨 pid 查找）
- (void)updateResolvedDataForToken:(NSString *)token
                            adType:(NSString *)adType
                            bucket:(HSSAdCacheBucketType)bucket
                      resolvedData:(NSDictionary *)data;

/// 保存 responseObject 模板（外层结构，creatives 已清空），按 adType 维度共享
- (void)saveTemplate:(NSDictionary *)templateDict
              adType:(NSString *)adType
              bucket:(HSSAdCacheBucketType)bucket;

/// 读取模板，用于无填充时拼接响应
- (nullable NSDictionary *)loadTemplateForAdType:(NSString *)adType
                                          bucket:(HSSAdCacheBucketType)bucket;

#pragma mark - p_bid_floor

/// 保存指定 pid 的 p_bid_floor（按 adType 分区，不区分 bucket）；floor <= 0 不更新
- (void)savePBidFloor:(NSInteger)floor
       forPlacementId:(NSString *)placementId
               adType:(NSString *)adType;

/// 读取指定 pid 上次下发的 p_bid_floor；无则返回 0
- (NSInteger)loadPBidFloorForPlacementId:(NSString *)placementId
                                   adType:(NSString *)adType;

#pragma mark - enable_ad_cache

/// 保存指定 adType 的 enable_ad_cache 开关（不区分 bucket）
- (void)saveEnableAdCache:(BOOL)enable forAdType:(NSString *)adType;

/// 读取指定 adType 的 enable_ad_cache 开关；未下发过则返回 nil
- (nullable NSNumber *)loadEnableAdCacheForAdType:(NSString *)adType;
- (BOOL)isDictExpired:(NSDictionary *)dict;
- (BOOL)shouldReportWithAd:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
