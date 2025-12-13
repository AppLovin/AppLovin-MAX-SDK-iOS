//
//  HSADXSDK.h
//  HSADXSDK
//
//  Created by admin on 2024/11/18.
//

#import <Foundation/Foundation.h>

// SDK初始化
#import <HSADXSDK/HSSdk.h>
#import <HSADXSDK/HSSdkInitialConfiguration.h>
#import <HSADXSDK/HSSdkSettings.h>
#import <HSADXSDK/HSSdkConfigurationBuilder.h>
#import <HSADXSDK/HSSdkConfiguration.h>

// 广告类
#import <HSADXSDK/HSSRewardedAd.h>
#import <HSADXSDK/HSSInterstitialAd.h>
#import <HSADXSDK/HSSAd.h>
#import <HSADXSDK/HSSADXBannerView.h>
#import <HSADXSDK/HSSInterstitialLocalAd.h>
#import <HSADXSDK/HSSRewardedLocalAd.h>

// 协议
#import <HSADXSDK/HSSAdDelegate.h>
#import <HSADXSDK/HSSRewardedAdDelegate.h>
#import <HSADXSDK/HSSPayDelegate.h>
#import <HSADXSDK/HSSBannerAdDelegate.h>
#import <HSADXSDK/HSSAdTrackerDelegate.h>

// 模型和枚举
#import <HSADXSDK/HSSBidResultModel.h>
#import <HSADXSDK/HSSAdMaterial.h>
#import <HSADXSDK/HSSAdAttribute.h>
#import <HSADXSDK/HSSReward.h>
#import <HSADXSDK/HSSAdFormat.h>
#import <HSADXSDK/HSSError.h>

// 工具类
#import <HSADXSDK/HSSMaxBiddingManager.h>
#import <HSADXSDK/HSSBannerBaseView.h>

// 工具类和分类
#import <HSADXSDK/UIView+HSSUtils.h>
#import <HSADXSDK/UIScreen+HSSafeArea.h>

//! Project version number for HSADXSDK.
FOUNDATION_EXPORT double HSADXSDKVersionNumber;

//! Project version string for HSADXSDK.
FOUNDATION_EXPORT const unsigned char HSADXSDKVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <HSADXSDK/PublicHeader.h>


