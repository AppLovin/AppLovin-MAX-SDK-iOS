//
//  ALVungleMediationAdapter.h
//  Adapters
//
//  Created by Christopher Cong on 10/19/18.
//  Copyright © 2018 AppLovin. All rights reserved.
//

#import <AppLovinSDK/AppLovinSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface ALVungleMediationAdapter : ALMediationAdapter<MASignalProvider, MAInterstitialAdapter, /* MAAppOpenAdapter */ MARewardedAdapter, MAAdViewAdapter, MANativeAdAdapter>

@end

NS_ASSUME_NONNULL_END
