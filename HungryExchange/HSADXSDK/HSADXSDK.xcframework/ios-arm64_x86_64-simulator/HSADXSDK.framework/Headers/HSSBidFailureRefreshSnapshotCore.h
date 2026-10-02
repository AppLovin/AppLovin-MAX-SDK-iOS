#import <Foundation/Foundation.h>

@class HSSAdsModel;
@class HSSBidResultModel;
@class HSSCreativeItemModel;
@class HSSAd;
@class  HSSAdLoad;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, HSSBidFailureRefreshLoadDecision) {
    /// 不属于本策略 / 未开启：调用方走原逻辑
    HSSBidFailureRefreshLoadDecisionProceedNormal = 0,
    /// 本策略吞掉本次 load 回调（已恢复旧缓存或选择丢弃旧缓存）
    HSSBidFailureRefreshLoadDecisionConsumed = 1,
};

@protocol HSSBidFailureRefreshSnapshotHost <NSObject>

@property (nonatomic, copy, readonly) NSString *placementId;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, HSSAdsModel *> *cacheAds;
@property (nonatomic, strong, nullable) HSSAdsModel *adsModel;
@property (nonatomic, strong, nullable) HSSAdLoad *adLoad;
@property (nonatomic, strong) HSSAd *hssAd;
@property (nonatomic, assign, getter=isBidFailureRetry) BOOL bidFailureRetry;

- (void)loadAd;
- (NSArray *)getCreatives:(HSSAdsModel *)adsModel placementId:(NSString *)placementId;

@end

@interface HSSBidFailureRefreshSnapshotCore : NSObject

/// `NSUserDefaults` 开关：hss_bid_failure_refresh_snapshot_enabled
+ (BOOL)isEnabled;

/// 是否正在进行一次静默刷新（用于外层计数逻辑避免并发/避免在 cache 被移除时取不到旧素材）
+ (BOOL)isInFlightForHost:(id<HSSBidFailureRefreshSnapshotHost>)host;

/// 上报竞价失败 lurls（AUCTION_LOSS 宏按配置替换）
+ (void)reportLossForCreative:(nullable HSSCreativeItemModel *)creative lossEcpm:(double)lossEcpm;

/// 返回 YES 表示“已接管 bid failure 并触发刷新”，调用方应直接 return
+ (BOOL)handleBidResultIfNeeded:(HSSBidResultModel *)bid
                           host:(id<HSSBidFailureRefreshSnapshotHost>)host
                 extraSnapshot:(nullable NSDictionary<NSString *, id> * (^)(void))extraSnapshot;

/// 处理一次 load success 的决策：调用方据此决定是否继续走原 success pipeline
+ (HSSBidFailureRefreshLoadDecision)handleLoadSuccessIfNeededForHost:(id<HSSBidFailureRefreshSnapshotHost>)host
                                                           adsModel:(HSSAdsModel *)adsModel
                                                      extraRestorer:(void (^)(NSDictionary<NSString *, id> *extra, BOOL keepOld))extraRestorer;

/// 处理一次 load failure：如属于刷新则恢复旧缓存并吞掉错误
+ (BOOL)handleLoadFailureIfNeededForHost:(id<HSSBidFailureRefreshSnapshotHost>)host
                                  error:(NSError *)error
                          extraRestorer:(void (^)(NSDictionary<NSString *, id> *extra, BOOL keepOld))extraRestorer;

@end

NS_ASSUME_NONNULL_END

