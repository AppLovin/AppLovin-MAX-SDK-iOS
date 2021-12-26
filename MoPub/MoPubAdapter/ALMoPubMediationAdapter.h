//
//  ALMoPubMediationAdapter.h
//  AppLovinSDK
//
//  Created by Chris Cong on 1/26/21.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALMediationAdapter.h"
#import "MAInterstitialAdapter.h"
#import "MARewardedAdapter.h"
#import "MAAdViewAdapter.h"

@interface ALMoPubMediationAdapter : ALMediationAdapter<MAInterstitialAdapter, MARewardedAdapter, MAAdViewAdapter>

@end
