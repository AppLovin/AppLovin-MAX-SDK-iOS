//
//  ALHyprMXMediationAdapter.h
//  Adapters
//
//  Created by Varsha Hanji on 10/1/20.
//  Copyright © 2020 AppLovin. All rights reserved.
//

#import "ALMediationAdapter.h"
#import "MAInterstitialAdapter.h"
#import "MARewardedAdapter.h"

@interface ALHyprMXMediationAdapter : ALMediationAdapter<MASignalProvider, MAAdViewAdapter, MAInterstitialAdapter, MARewardedAdapter>

@end
