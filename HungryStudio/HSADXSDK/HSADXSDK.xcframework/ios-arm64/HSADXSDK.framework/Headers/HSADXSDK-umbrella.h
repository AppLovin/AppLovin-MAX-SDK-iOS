#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "HSADXSDK.h"
#import "HSSdk.h"
#import "HSSdkInitialConfiguration.h"
#import "HSSdkSettings.h"
#import "HSSdkConfigurationBuilder.h"
#import "HSSdkConfiguration.h"
#import "HSSRewardedAd.h"
#import "HSSInterstitialAd.h"
#import "HSSAd.h"
#import "HSSADXBannerView.h"
#import "HSSInterstitialLocalAd.h"
#import "HSSRewardedLocalAd.h"
#import "HSSAdDelegate.h"
#import "HSSRewardedAdDelegate.h"
#import "HSSPayDelegate.h"
#import "HSSBannerAdDelegate.h"
#import "HSSAdTrackerDelegate.h"
#import "HSSBidResultModel.h"
#import "HSSAdMaterial.h"
#import "HSSAdAttribute.h"
#import "HSSReward.h"
#import "HSSAdFormat.h"
#import "HSSError.h"
#import "HSSMaxBiddingManager.h"
#import "HSSBannerBaseView.h"

FOUNDATION_EXPORT double HSADXSDKVersionNumber;
FOUNDATION_EXPORT const unsigned char HSADXSDKVersionString[];

