//
//  ALInneractiveMediationAdapter.h
//  Adapters
//
//  Created by Christopher Cong on 10/11/18.
//  Copyright © 2018 AppLovin. All rights reserved.
//

#import "ALMediationAdapter.h"
#import "MAInterstitialAdapter.h"
#import "MARewardedAdapter.h"
#import "MAAdViewAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALInneractiveMediationAdapter : ALMediationAdapter<MASignalProvider, MAInterstitialAdapter, MARewardedAdapter, MAAdViewAdapter>

@end

NS_ASSUME_NONNULL_END
