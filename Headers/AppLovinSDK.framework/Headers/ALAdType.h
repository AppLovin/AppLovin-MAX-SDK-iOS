//
//  ALAdType.h
//  AppLovinSDK
//
//  Copyright © 2020 AppLovin Corporation. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

/**
 * This class defines the possible types of an interstitial ad (i.e. regular or incentivized/rewarded).
 */
@interface ALAdType : NSObject

/**
 * A standard advertisement that does not provide a reward to the user.
 */
@property (class, nonatomic, strong, readonly) ALAdType *regular;

/**
 * A rewarded ad, which will provide the user virtual currency upon completion.
 */
@property (class, nonatomic, strong, readonly) ALAdType *incentivized;

/**
 * A rewarded interstitial ad, which the user can skip or be granted a reward upon successful completion of the ad.
 */
@property (class, nonatomic, strong, readonly) ALAdType *autoIncentivized;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
