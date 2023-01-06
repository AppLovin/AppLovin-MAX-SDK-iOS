//
//  ALCSJMediationAdapter.h
//  Adapters
//
//  Created by Vedant Mehta on 09/30/22.
//  Copyright © 2022 AppLovin. All rights reserved.
//

#import <AppLovinSDK/AppLovinSDK.h>

@interface ALCSJMediationAdapter : ALMediationAdapter <MASignalProvider, MAInterstitialAdapter, MAAppOpenAdapter, MARewardedAdapter, MAAdViewAdapter, MANativeAdAdapter>

@end
