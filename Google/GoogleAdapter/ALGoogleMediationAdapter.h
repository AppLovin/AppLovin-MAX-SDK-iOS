//
//  ALGoogleMediationAdapter.h
//  AppLovin MAX Google AdMob Adapter
//
//  Created by Santosh Bagadi on 8/31/18.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import <AppLovinSDK/AppLovinSDK.h>

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAdsDefines.h>
#import <GoogleMobileAds/GADAdFormat.h>
#import <GoogleMobileAds/GADRequest.h>

NS_ASSUME_NONNULL_BEGIN

@interface ALGoogleMediationAdapter : ALMediationAdapter<MASignalProvider, MAInterstitialAdapter, MAAppOpenAdapter, MARewardedInterstitialAdapter, MARewardedAdapter, MAAdViewAdapter, MANativeAdAdapter>

/**
 * Maps the provided ad network's error to an instance of @c MAAdapterError.
 */
+ (MAAdapterError *)toMaxError:(NSError *)googleAdsError;

@end

NS_ASSUME_NONNULL_END
