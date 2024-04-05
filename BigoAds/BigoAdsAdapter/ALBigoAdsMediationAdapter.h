//
//  BigoAdsMediationAdapter.h
//  BigoAds
//
//  Created by Avi Leung on 2/13/24.
//

#import <AppLovinSDK/AppLovinSDK.h>

@interface ALBigoAdsMediationAdapter : ALMediationAdapter <MASignalProvider, MAInterstitialAdapter, MAAppOpenAdapter, MARewardedAdapter, MAAdViewAdapter, MANativeAdAdapter>

@end
