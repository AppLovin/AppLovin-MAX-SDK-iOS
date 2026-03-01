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

@end

NS_ASSUME_NONNULL_END
