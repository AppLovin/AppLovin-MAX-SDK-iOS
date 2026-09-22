#import <Foundation/Foundation.h>
#import "HSSBidFailureRefreshSnapshotCore.h"

@class HSSRewardedAd;
@class HSSBidResultModel;
@class HSSAdsModel;
@class HSSError;

NS_ASSUME_NONNULL_BEGIN

@interface HSSRewardedBidFailureRefreshSnapshot : NSObject

+ (BOOL)handleBidResultIfNeeded:(HSSBidResultModel *)bid forAd:(HSSRewardedAd *)ad;

+ (HSSBidFailureRefreshLoadDecision)handleLoadSuccessIfNeededForAd:(HSSRewardedAd *)ad adsModel:(HSSAdsModel *)adsModel;

+ (BOOL)handleLoadFailureIfNeededForAd:(HSSRewardedAd *)ad error:(HSSError *)error;

@end

NS_ASSUME_NONNULL_END

