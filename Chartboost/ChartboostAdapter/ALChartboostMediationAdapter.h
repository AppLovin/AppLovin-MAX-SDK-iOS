//
//  ALChartboostMediationAdapter.h
//  Adapters
//
//  Created by Thomas So on 1/8/19.
//  Copyright © 2019 AppLovin. All rights reserved.
//

#import "ALMediationAdapter.h"
#import "MAInterstitialAdapter.h"
#import "MARewardedAdapter.h"

@interface ALChartboostMediationAdapter : ALMediationAdapter<MAInterstitialAdapter, MARewardedAdapter, MAAdViewAdapter>

@end
