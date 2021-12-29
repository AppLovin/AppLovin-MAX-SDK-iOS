//
//  ALTencentGDTMediationAdapter.h
//  AppLovinSDK
//
//  Created by Thomas So on 6/30/19.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALMediationAdapter.h"
#import "MAInterstitialAdapter.h"
#import "MARewardedAdapter.h"
#import "MAAdViewAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALTencentGDTMediationAdapter : ALMediationAdapter<MAAdViewAdapter, MAInterstitialAdapter, MARewardedAdapter>

@end

NS_ASSUME_NONNULL_END
