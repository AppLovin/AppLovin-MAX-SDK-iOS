//
//  HSSADXBannerView.h
//  HSADXSDK
//
//  Created by biyingquan on 2025/4/8.
//

#import <HSADXSDK/HSADXSDK.h>
#import "HSSBannerBaseView.h"
#import <HSADXSDK/HSSBannerAdDelegate.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSSADXBannerView : HSSBannerBaseView
/// 素材 id
@property (nonatomic, copy, readonly) NSString *crid;

@property (nonatomic, copy, readonly) NSString *dspName;

@property (nonatomic, weak, nullable) id<HSSBannerAdDelegate> delegate;

- (instancetype)initWithPlacementId:(NSString *)placementId adSize:(CGSize)adSize;

/**
 * 加载广告
 */
- (void)loadAd;

/**
 * 根据MaxBidResponse加载广告
 *
 * @param maxBidResponse MaxBidResponse
 */
- (void)loadAdWithMaxBidResponse:(nullable NSString *)maxBidResponse;

@end

NS_ASSUME_NONNULL_END
