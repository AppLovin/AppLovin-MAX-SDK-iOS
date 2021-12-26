//
//  MAUnityMediationAdapter.h
//  AppLovinSDK
//
//  Created by Santosh Bagadi on 9/2/18.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALMediationAdapter.h"
#import "MAInterstitialAdapter.h"
#import "MARewardedAdapter.h"
#import "MAAdViewAdapter.h"

@interface ALUnityAdsMediationAdapter : ALMediationAdapter<MASignalProvider, MAInterstitialAdapter, MARewardedAdapter, MAAdViewAdapter>

@end
