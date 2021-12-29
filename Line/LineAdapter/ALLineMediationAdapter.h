//
//  ALLineMediationAdapter.h
//  AppLovinSDK
//
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALMediationAdapter.h"
#import "MANativeAdAdapter.h"

@interface ALLineMediationAdapter : ALMediationAdapter<MAInterstitialAdapter, MARewardedAdapter, MAAdViewAdapter, MANativeAdAdapter>

@end
