//
//  HSSInterstitialLocalAd.h
//  HSADXSDK
//
//  Created by biyingquan on 2025/7/9.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <HSADXSDK/HSSAdDelegate.h>
#import <HSADXSDK/HSSPayDelegate.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSInterstitialLocalAd : NSObject

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


- (instancetype)initWithAdPlacement:(NSString *)placementId;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (void)showAd NS_UNAVAILABLE;

/**
 *  展示交叉推广广告
 *@param isReport   是否上报 adx_sdk_ad_revenue_cross事件
 */
- (void)showAd:(double)ecpm revenueCrossReport:(BOOL)isReport;

/**
 * 设置参数
 *
 * @param key   Parameter key.
 * @param value Parameter value.
 */
- (void)setExtraParameterForKey:(NSString *)key value:(nullable NSString *)value;

@end

NS_ASSUME_NONNULL_END
