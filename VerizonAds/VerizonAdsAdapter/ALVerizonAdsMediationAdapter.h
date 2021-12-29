//
//  MAVerizonAdsMediationAdapter.h
//  AppLovinSDK
//
//  Created by Santosh Bagadi on 4/7/19.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALMediationAdapter.h"
#import "MAInterstitialAdapter.h"
#import "MARewardedAdapter.h"
#import "MAAdViewAdapter.h"

@interface ALVerizonAdsMediationAdapter : ALMediationAdapter<MAInterstitialAdapter, MARewardedAdapter, MAAdViewAdapter, MASignalProvider>

@end
