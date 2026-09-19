#import <Foundation/Foundation.h>
#import "HSSBidFailureRefreshSnapshotCore.h"

@class HSSInterstitialAd;
@class HSSBidResultModel;
@class HSSAdsModel;
@class HSSError;

NS_ASSUME_NONNULL_BEGIN

@interface HSSInterstitialBidFailureRefreshSnapshot : NSObject

+ (BOOL)handleBidResultIfNeeded:(HSSBidResultModel *)bid forAd:(HSSInterstitialAd *)ad;

+ (HSSBidFailureRefreshLoadDecision)handleLoadSuccessIfNeededForAd:(HSSInterstitialAd *)ad adsModel:(HSSAdsModel *)adsModel;

+ (BOOL)handleLoadFailureIfNeededForAd:(HSSInterstitialAd *)ad error:(HSSError *)error;

@end

NS_ASSUME_NONNULL_END

