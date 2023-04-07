//
//  ALMobileFuseMediationAdapter.h
//  Adapters
//
//  Created by Wootae on 9/30/22.
//  Copyright © 2022 AppLovin. All rights reserved.
//

#import <AppLovinSDK/AppLovinSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface ALMobileFuseMediationAdapter : ALMediationAdapter <MASignalProvider, MAInterstitialAdapter, MARewardedAdapter, MAAdViewAdapter, MANativeAdAdapter>

@end

NS_ASSUME_NONNULL_END
