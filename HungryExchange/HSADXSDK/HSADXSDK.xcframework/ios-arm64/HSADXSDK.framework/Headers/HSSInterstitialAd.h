//
//  HSSInterstitialAd.h
//  HSADXSDK
//
//  Created by admin on 2024/11/27.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <HSADXSDK/HSSAdDelegate.h>
#import <HSADXSDK/HSSPayDelegate.h>

@class HSSBidResultModel;
NS_ASSUME_NONNULL_BEGIN

@interface HSSInterstitialAd : NSObject

/**
 * 广告是否已经准备
 */
@property (nonatomic, assign, readonly, getter=isReady) BOOL ready;

/**
 * 广告是否已经准备展示
 * 与isReady的区别在与， 内部会统计ready率， 因此外界只有在广告参与比价或者调用广告展示时，使用该值判断
 */
@property (nonatomic, assign, readonly, getter=isReadyForShow) BOOL readyForShow;

/**
 * prebid广告是否已经准备
 */
@property (nonatomic, assign, readonly, getter=isPrebidReady) BOOL prebidReady;

/**
 * 离线广告是否已经准备
 */
@property (nonatomic, assign, readonly, getter=isOfflineReady) BOOL offlineReady;

/**
 *  广告代理
 */
@property (nonatomic, weak, nullable) id<HSSAdDelegate> delegate;

/**
 *  收入代理
 */
@property (nonatomic, weak, nullable) id<HSSPayDelegate> payDelegate;

/**
 * 当前广告唯一 id
 */
@property (nonatomic, copy, readonly) NSString *placementId;

/**
 *  广告 ecpm
 */
@property (nonatomic, assign, readonly) double ecpm;


/**
 *  adx 直连广告请求的bidfloor
 */
@property (nonatomic, assign) double bidfloor;

/**
 *  adx 请求广告的额外信息， 针对每一次load请求
 */
@property (nonatomic, copy, nullable) NSDictionary *extraInfo;

/**
 *  广告服务端ecpm
 */
@property (nonatomic, assign, readonly) double serverEcpm;

/**
 * 创建插屏广告实例
 *@param placementId ad unit id to load ads for.
 */
- (instancetype)initWithAdPlacement:(NSString *)placementId;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/**
 * 加载广告
 */
- (void)loadAd;

/**
 * 加载Prebid广告 表示这次load来自prebid
 */
- (void)loadAdFromPrebid;

/**
 * 加载广告并设置额外参数
 * 这些参数仅对本次加载有效，不会影响已设置的参数
 *
 * @param extraParameters 额外参数字典，键值对必须是NSString类型
 */
- (void)loadAdWithExtraParameters:(nullable NSDictionary<NSString *, NSString *> *)extraParameters;


/**
 * 根据MaxBidResponse加载广告
 *
 * @param maxBidResponse MaxBidResponse
 */
- (void)loadAdWithMaxBidResponse:(nullable NSString *)maxBidResponse;

/**
 * 加载在线的offline广告
 */

- (void)loadOfflineAd;

/**
 *  展示广告
 */
- (void)showAd;

/**
 *  展示交叉推广广告
 */
- (void)showAd:(double)ecpm;

/**
 *  展示交叉推广广告
 *@param isReport   是否上报 adx_sdk_ad_revenue_cross事件
 */
- (void)showAd:(double)ecpm revenueCrossReport:(BOOL)isReport;

/**
 *  展示广告，并且通过参数fromAdapter判断是否来自adapter的展示操作
 */
- (void)showAdFromAdapter:(BOOL)fromAdapter;

/**
 * 设置参数
 *
 * @param key   Parameter key.
 * @param value Parameter value.
 */
- (void)setExtraParameterForKey:(NSString *)key value:(nullable NSString *)value;

/**
 * @param bid 竞价结果 model
 */
-(void)bidResult:(HSSBidResultModel *)bid;

// 获取对外真实报价（ecpm）
- (double)priceWithBidContext:(NSArray<NSDictionary *> *)bidContext;

// 旧方法， 合入之后删除
- (double)priceWithHighestEcpm:(double)ecpm;

@end

NS_ASSUME_NONNULL_END
