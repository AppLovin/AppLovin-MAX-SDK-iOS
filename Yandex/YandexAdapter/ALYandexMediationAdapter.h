//
//  ALYandexMediationAdapter.h
//  AppLovinSDK
//
//  Created by Andrew Tian on 9/17/19.
//  Copyright © 2019 AppLovin. All rights reserved.
//

#import <AppLovinSDK/AppLovinSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface ALYandexMediationAdapter : ALMediationAdapter <MASignalProvider, MAInterstitialAdapter, MARewardedAdapter, MAAdViewAdapter, MANativeAdAdapter>

@end

NS_ASSUME_NONNULL_END
