//
//  ALBidscubeMediationAdapter.h
//  AppLovin MAX Bidscube Adapter
//
//  Created by AppLovin Corporation on 1/27/25.
//  Copyright © 2025 AppLovin Corporation. All rights reserved.
//

#import <AppLovinSDK/AppLovinSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface ALBidscubeMediationAdapter : ALMediationAdapter <MAInterstitialAdapter, MARewardedAdapter, MAAdViewAdapter, MANativeAdAdapter, MASignalProvider>

/**
 * Maps the provided ad network's error to an instance of @c MAAdapterError.
 */
+ (MAAdapterError *)toMaxError:(NSError *)bidscubeError;

@end

NS_ASSUME_NONNULL_END

