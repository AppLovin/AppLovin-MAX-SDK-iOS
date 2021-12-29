//
//  ALByteDanceMediationAdapter.h
//  Adapters
//
//  Created by Thomas So on 12/25/18.
//  Copyright © 2018 AppLovin. All rights reserved.
//

#import "ALMediationAdapter.h"
#import "MANativeAdAdapter.h"

@interface ALByteDanceMediationAdapter : ALMediationAdapter<MASignalProvider, MAInterstitialAdapter, MARewardedAdapter, MAAdViewAdapter, MANativeAdAdapter>

@end
