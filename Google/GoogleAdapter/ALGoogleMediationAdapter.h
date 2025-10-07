//
//  ALGoogleMediationAdapter.h
//  AppLovin MAX Google AdMob Adapter
//
//  Created by Santosh Bagadi on 8/31/18.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import <AppLovinSDK/AppLovinSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface ALGoogleMediationAdapter : ALMediationAdapter <MASignalProvider, MAInterstitialAdapter, MAAppOpenAdapter, MARewardedAdapter, MAAdViewAdapter, MANativeAdAdapter>

/**
 * Maps the provided ad network's error to an instance of @c MAAdapterError.
 */
+ (MAAdapterError *)toMaxError:(NSError *)googleAdsError;

@end

NS_ASSUME_NONNULL_END
