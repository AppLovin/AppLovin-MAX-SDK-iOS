//
//  HSSAdsModel.h
//  HSADXSDK
//
//  Created by admin on 2024/11/26.
//

#import "HSSBaseModel.h"
#import <HSADXSDK/HSSAdFormat.h>
@class HSSCreativeItemModel;
NS_ASSUME_NONNULL_BEGIN

@interface HSSPlacementsModel : HSSBaseModel

@property (nonatomic, assign) NSInteger code;
// 是否为混合广告，0否 1是
@property (nonatomic, assign) NSInteger is_mix;
// 混合类型 0：非混合类型，is_mix = 1 时不会为 0 1：双banner 2：双video
@property (nonatomic, assign) NSInteger mix_cr_type;
@property (nonatomic, copy) NSString *placement;
@property (nonatomic, strong) NSArray<HSSCreativeItemModel *> *creatives;
// 重试时间间隔，元素个数代表重试次数， 元素值代表本次重试间隔
// 比如[1, 2, 4]，重试次数为3次， 第一次重试是1s后， 第二次重试是2s后， 第三次重试是4s后
@property (nonatomic, copy) NSArray *retry_time;

/// 是否提前加载h5广告， 0: 是， 1: 否（展示时再加载)
@property (nonatomic, assign) BOOL not_preload;

///广告位底价，原价乘以100w
@property (nonatomic, assign) NSInteger p_bid_floor;
@end

@interface HSSDataModel : HSSBaseModel

@property (nonatomic, copy) NSString *abcfgs;
@property (nonatomic, strong) NSArray<HSSPlacementsModel *> *placements;

// Max bid时服务端生成的rid
@property (nonatomic, copy) NSString *rid;

@end

@interface HSSAdsModel : HSSBaseModel

@property (nonatomic, strong) HSSDataModel *data;
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, assign) NSInteger s_r_t;
@property (nonatomic, assign) NSInteger s_s_t;

@property (nonatomic, assign) BOOL isAdDownloading;

/// 广告是否正在展示
@property (nonatomic, assign) BOOL isAdShowing;

/// 广告是否是vast的wrapper类型广告
 @property (nonatomic, assign) BOOL isVastWrapperAd;

@property (nonatomic, assign) BOOL isOffline;

/// ad 格式
@property (nonatomic, assign) HSSAdFormatType adFormat;

// 当前广告关联的来自max的adUnitId;
@property (nonatomic, copy) NSString *associateMaxAdUnitId;

-(double)ecpmById:(NSString *)placementId;

-(HSSCreativeItemModel *)findNeedShowItem:(NSString *)placementId;

- (HSSPlacementsModel *)findPlacementItem:(NSString *)placementId;

/// 获取第一个素材
- (HSSCreativeItemModel *)findFirstItemModel:(NSString *)placementId;

/// 该 creative 是否需要 VAST 解析（纯模型推导，供请求层埋点与展示层埋点共用）
- (BOOL)needVastParseForCreative:(nullable HSSCreativeItemModel *)creative
                       placement:(nullable HSSPlacementsModel *)placement;

/// 便捷版：取 placementId 对应的待展示 creative 与 placement 推导
- (BOOL)needVastParseForPlacement:(NSString *)placementId;

/**
 @param placementId  ad id
 @param sucess  done = YES 加载完成  NO 其中有一个失效
 */
- (void)loadMaterialById:(NSString *)placementId sucess:(void (^)(BOOL done))sucess;

/**
 @param placementId  ad id
 @return YES:准备好 NO: 没有准备好
 */
-(BOOL)isReady:(NSString *)placementId;

/**
 @param placementId  ad id
 @param sucess  done = YES 加载完成  NO 全部失效
 */
- (void)loadOfflineMaterialById:(NSString *)placementId sucess:(void (^)(BOOL done))sucess;
/**
 @param placementId  ad id
 */
- (void)loadOfflineImageMaterialById:(NSString *)placementId;

@end

NS_ASSUME_NONNULL_END
