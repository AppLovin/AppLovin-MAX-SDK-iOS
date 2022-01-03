//
//  ALGoogleAdManagerMediationAdapter.h
//  AppLovinSDK
//
//  Created by Santosh Bagadi on 12/3/19.
//  Copyright © 2022 AppLovin Corporation. All rights reserved.
//

#import <AppLovinSDK/AppLovinSDK.h>

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAdsDefines.h>
#import <GoogleMobileAds/GADAdFormat.h>
#import <GoogleMobileAds/GADRequest.h>

@interface ALGoogleAdManagerMediationAdapter : ALMediationAdapter<MAInterstitialAdapter, MARewardedInterstitialAdapter, MARewardedAdapter, MAAdViewAdapter, MANativeAdAdapter>

@end
