//
//  HSSAdLoad.h
//  HSADXSDK
//
//  Created by admin on 2024/11/29.
//

#import <Foundation/Foundation.h>
#import <HSADXSDK/HSSAdCacheCompareModule.h>

@class HSSError;
@class HSSAdsModel;
NS_ASSUME_NONNULL_BEGIN

/// 单次请求的只读上下文快照：在 successBlock 回调时随 adsModel 一并交付，
/// 承载只有请求层才知道的事实（rid 等）以及本次请求的固定属性。
/// 全部 readonly，宿主持有后不可篡改，避免跨请求读取 adLoad 可变状态造成的时序混淆。
@interface HSSAdRequestContext : NSObject

@property (nonatomic, copy, readonly) NSString *sid;
@property (nonatomic, copy, readonly) NSString *rid;
@property (nonatomic, copy, readonly) NSString *placementId;
@property (nonatomic, copy, readonly) NSString *ad_mediation;
@property (nonatomic, assign, readonly) HSSAdCacheBucketType cacheBucketSnapshot;

- (instancetype)initWithSid:(NSString *)sid
                        rid:(NSString *)rid
                placementId:(NSString *)placementId
               ad_mediation:(NSString *)ad_mediation
        cacheBucketSnapshot:(HSSAdCacheBucketType)cacheBucketSnapshot NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

typedef void(^SuccessBlock)(NSURLResponse * _Nullable response, HSSAdsModel *adsModel, HSSAdRequestContext *context);
typedef void(^FailureBlock)(NSURLResponse * _Nullable response, HSSError *error);

@interface HSSAdLoad : NSObject

/// 生成s_id
+(NSString *)startLoadId;

/// 广告位 id
@property (nonatomic, copy) NSString *placementId;

/// 需要重试总次数
@property (nonatomic, assign) NSUInteger retryTotal;

/// 重试间隔时间ms
@property (nonatomic, assign) NSInteger retryInterval;

/// 是否重试完成 YES 完成, NO 未完成 ,默认 NO
@property (nonatomic, assign,getter=isRetryDone) BOOL retryDone;

/// 请求成功 block
@property (nonatomic, copy) SuccessBlock successBlock;

/// 请求失败 block
@property (nonatomic, copy) FailureBlock failureBlock;

/// load 的广告是否离线广告
@property (nonatomic, assign) BOOL isOffline;

/// 业务在 successBlock 内置 YES：本次 HTTP 回包未被沿用（如 BFRS 吞并沿用旧缓存）；仍会上报 `adx_sdk_ad_request`，且 params 中带 `request_result_unused=1`
@property (nonatomic, assign) BOOL requestResultUnused;

-(void)loadAds:(NSDictionary *)parameters;

// 统一处理max 返回的bidResponse(已包含ads接口信息)
- (void)loadMaxBidAdWithBidResponse:(NSString *)bidResponse params:(NSDictionary *)parameters;

@end

NS_ASSUME_NONNULL_END
