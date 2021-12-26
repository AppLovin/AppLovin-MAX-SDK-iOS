//
//  ALInMobiMediationAdapter.h
//  AppLovinSDK
//
//  Created by Thomas So on 2/9/19.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import "ALMediationAdapter.h"
#import "MAAdViewAdapter.h"
#import "MAInterstitialAdapter.h"
#import "MARewardedAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALInMobiMediationAdapter : ALMediationAdapter<MAAdViewAdapter, MAInterstitialAdapter, MARewardedAdapter, MASignalProvider>

@end

NS_ASSUME_NONNULL_END
