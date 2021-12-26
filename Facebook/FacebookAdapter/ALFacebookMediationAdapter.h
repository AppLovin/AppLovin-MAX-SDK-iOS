//
//  MAFacebookMediationAdapter.h
//  AppLovinSDK
//
//  Created by Santosh Bagadi on 8/31/18.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALMediationAdapter.h"
#import "MAInterstitialAdapter.h"
#import "MARewardedAdapter.h"
#import "MAAdViewAdapter.h"
#import "MANativeAdAdapter.h"
#import "MASignalProvider.h"

@interface ALFacebookMediationAdapter : ALMediationAdapter<MAInterstitialAdapter, MARewardedAdapter, MARewardedInterstitialAdapter, MAAdViewAdapter, MANativeAdAdapter, MASignalProvider>

@end
