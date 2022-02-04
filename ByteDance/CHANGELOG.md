# Changelog

## 4.2.0.4.3
* Fix native ads advertiser text not rendering.
* Fix native ads media view not rendering.

## 4.2.0.4.2
* Add non-bidding support for native ads.

## 4.2.0.4.1
* Moved impression callback to `-[BUNativeExpressBannerViewDelegate nativeExpressBannerAdViewWillBecomVisible]`.

## 4.2.0.4.0
* Certified with ByteDance SDK 4.2.0.4.
* Update open source versions to allow compilation with AppLovin SDK v11.0.0+.

## 4.2.0.2.2
* Properly destroy native ad.

## 4.2.0.2.1
* Fix icon view never getting registered for interaction.

## 4.2.0.2.0
* Certified with ByteDance SDK 4.2.0.2.
* Remove non-bidding support for native ads.

## 4.1.0.2.1
* Add support for native custom ads and updated native template ad support.

## 4.1.0.2.0
* Certified with ByteDance SDK 4.1.0.2.

## 4.0.0.5.0
* Certified with ByteDance SDK 4.0.0.5.

## 4.0.0.1.0
* Certified with ByteDance SDK 4.0.0.1.

## 3.9.0.4.2
* Fix issue causing native ads to time out.

## 3.9.0.4.1
* Initial support for true native ads.

## 3.9.0.4.0
* Certified with ByteDance SDK 3.9.0.4.

## 3.9.0.3.0
* Certified with ByteDance SDK 3.9.0.3.

## 3.7.0.7.0
* Certified with ByteDance SDK 3.7.0.7.

## 3.6.1.5.0
* Certified with ByteDance SDK 3.6.1.5.
* Updated new SDK initialization method `[BUAdSDKManager startWithAsyncCompletionHandler:]`.
* Update podspec to use `pod_target_xcconfig` over the deprecated `xcconfig`.

## 3.5.1.0.0
* Certified with ByteDance SDK 3.5.1.0.
* Set mediation provider for ByteDance when the adapter is initialized.
* Updated the minimum required iOS version to 10.0 in Pod Spec.
* Addded `c++abi` library required by ByteDance to Pod Spec. 

## 3.4.4.3.0
* Certified with ByteDance SDK 3.4.4.3.

## 3.4.2.3.0
* Certify against ByteDance SDK 3.4.2.3 which is their global SDK with the China subspec. `+[BUAdSDKManager setTerritory:]` is called appropriately for domestic (CN) and international (global) traffic prior to init.
* Use 320x50 size for leaders.
* Add support for native ad views.
* Add support to pass 3rd-party error code and description to SDK.
* Update podspec source from bintray to S3.

## 3.3.6.2.0
* Certified with ByteDance SDK 3.3.6.2.

## 3.3.6.1.0
* Certified with ByteDance SDK 3.3.6.1.
* Removed the usage of deprecated `isAdValid` from `showInterstitialAdForParameters:andNotify:` and `showRewardedAdForParameters:andNotify:`.
* Remove usage of deprecated `-[BUNativeExpressBannerView initWithSlotID:rootViewController:adSize:IsSupportDeepLink:]` method in lieu of `-[BUNativeExpressBannerView initWithSlotID:rootViewController:adSize:]`. 

## 3.3.1.5.0
* Certified with ByteDance SDK 3.3.1.5.

## 3.3.0.5.2
* Remove support for setting user consent based on `"gdpr_applies"`.

## 3.3.0.5.1
* Update `rewardedVideoAdServerRewardDidFail:` callback to `rewardedVideoAdServerRewardDidFail: error:`.
* Update raw error codes with APIs. 

## 3.3.0.5.0
* Certified with ByteDance SDK 3.3.0.5.

## 3.3.0.4.0
* Certified with ByteDance SDK 3.3.0.4.

## 3.2.6.2.1
* Update to check for `gdpr_applies` server parameter.

## 3.2.6.2.0
* Certified with ByteDance SDK 3.2.6.2.

## 3.2.5.2.0
* Certified with ByteDance SDK 3.2.5.2.

## 3.2.5.1.1
* Update 7000000 version check to 6140000.
* Update initialization log.

## 3.2.5.1.0
* Certified with ByteDance SDK 3.2.5.1.
* Removed the i386 slice. Adapter will no longer work on 32-bit simulators.

## 3.2.0.1.0
* Certified with ByteDance SDK 3.2.0.1.

## 3.1.0.9.2
* Update 70000 version check to 7000000.

## 3.1.0.9.1
* Update 61400 version check to 70000.

## 3.1.0.9.0
* Certified with ByteDance SDK 3.1.0.9.

## 3.1.0.5.4
* Add support for bidding on interstitials, rewarded, banners, and medium rectangle ads.

## 3.1.0.5.3
* Fix incorrect adapter version returned by the adapter.

## 3.1.0.5.2
* Updated to not set privacy settings if nil.

## 3.1.0.5.1
* Roll back privacy changes.

## 3.1.0.5.0
* Certified with SDK 3.1.0.5.
* Updated to not set privacy settings if nil.
* Add COPPA support.

## 3.0.0.6.0
* Certified with SDK 3.0.0.6.

## 3.0.0.2.0
* Certified with SDK 3.0.0.2.

## 2.9.0.1.2
* Update GDPR settings in ByteDance adapter initialization.

## 2.9.0.1.1
* Add support for banner and MREC ads.

## 2.9.0.1.0
* Certified with SDK 2.9.0.1.

## 2.8.0.1.1
* Re-certified with last SDK that did not have integration problems 2.5.1.5.

## 2.8.0.1.0
* Certified with SDK 2.8.0.1.

## 2.5.1.5.0
* Certified with SDK 2.5.1.5.

## 2.4.6.7.0
* Updated the minimum required AppLovin SDK version to 6.5.0.

## 2.3.0.3.0
* Certified with SDK 2.3.0.3.

## 2.1.0.2.1
* Use `fullscreenVideoAdDidVisible:` and `rewardedVideoAdDidVisible:` for the `-[MAAdDelegate didDisplayAd:]` callback. 

## 2.1.0.2.0
* Certified with SDK 2.1.0.2.
* Add support for initialization status.

## 2.0.1.2.1
* Add Unity support for automatic dependency resolution. Please ensure that you are on the latest [AppLovin MAX Unity Plugin](https://bintray.com/applovin/Unity/applovin-max-unity-plugin).
* Add support for extra reward options.

## 2.0.1.2.0
* Certified with SDK 2.0.1.2.

## 1.9.8.5.0
* Certified with SDK 1.9.8.5.

## 1.9.8.2.0
* Initial commit.
