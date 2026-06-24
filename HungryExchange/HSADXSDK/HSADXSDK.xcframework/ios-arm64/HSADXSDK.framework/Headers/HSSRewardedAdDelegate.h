//
//  HSSRewardedAdDelegate.h
//  HSADXSDK
//
//  Created by admin on 2024/12/3.
//

#import <HSADXSDK/HSSAdDelegate.h>

@class HSSAd;
@class HSSReward;
NS_ASSUME_NONNULL_BEGIN

@protocol HSSRewardedAdDelegate <HSSAdDelegate>

- (void)didRewardUserForAd:(HSSAd *)ad withReward:(HSSReward *)reward;

@end

NS_ASSUME_NONNULL_END
