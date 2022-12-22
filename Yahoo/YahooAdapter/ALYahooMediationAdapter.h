//
//  ALYahooMediationAdapter.h
//  AppLovinSDK
//
//  Created by Santosh Bagadi on 4/7/19.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import <AppLovinSDK/AppLovinSDK.h>

@interface ALYahooMediationAdapter : ALMediationAdapter<MASignalProvider, MAInterstitialAdapter, MARewardedAdapter, MAAdViewAdapter, MANativeAdAdapter>

@end

@interface ALVerizonAdsMediationAdapter : ALYahooMediationAdapter

@end
