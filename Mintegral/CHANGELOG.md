# Changelog

## 7.6.7.0.0
* Certified with Mintegral SDK 7.6.7.

## 7.6.6.0.0
* Certified with Mintegral SDK 7.6.6.

## 7.6.4.0.0
* Certified with Mintegral SDK 7.6.4.
* Updated minimum Xcode requirement to 15.0.

## 7.6.3.0.0
* Certified with Mintegral SDK 7.6.3.

## 7.6.2.0.0
* Certified with Mintegral SDK 7.6.2.

## 7.6.1.0.0
* Certified with Mintegral SDK 7.6.1.

## 7.6.0.0.0
* Certified with Mintegral SDK 7.6.0.
* Remove deprecated callbacks `didStartRewardedAdVideo` and `didCompleteRewardedAdVideo`.

## 7.5.9.0.0
* Certified with Mintegral SDK 7.5.9.

## 7.5.8.0.0
* Certified with Mintegral SDK 7.5.8.

## 7.5.7.0.0
* Certified with Mintegral SDK 7.5.7.

## 7.5.6.0.0
* Certified with Mintegral SDK 7.5.6.

## 7.5.5.0.0
* Certified with Mintegral SDK 7.5.5.

## 7.5.4.0.2
* Add `kMTGErrorCodeSocketInvalidStatus` and `kMTGErrorCodeSocketInvalidContent` error codes to error mapping.

## 7.5.4.0.1
* Update to retrieve creative ID and set channel code/ID using new APIs.
* Add `kMTGErrorCodeAdsCountInvalid` error code to error mapping.
* Now requires MAX SDK version 6.15.0 or higher.

## 7.5.4.0.0
* Certified with Mintegral SDK 7.5.4.

## 7.5.3.0.0
* Certified with Mintegral SDK 7.5.3.

## 7.5.2.0.0
* Certified with Mintegral SDK 7.5.2.

## 7.5.1.0.0
* Certified with Mintegral SDK 7.5.1.
* Note: This is the first Mintegral SDK with TCF v2 compliance.

## 7.5.0.0.0
* Certified with Mintegral SDK 7.5.0.
* Updated minimum iOS version to 11.0.

## 7.4.9.0.0
* Certified with Mintegral SDK 7.4.9.

## 7.4.8.0.0
* Certified with Mintegral SDK 7.4.8.

## 7.4.7.0.0
* Certified with Mintegral SDK 7.4.7.

## 7.4.6.0.0
* Certified with Mintegral SDK 7.4.6.

## 7.4.4.0.0
* Certified with Mintegral SDK 7.4.4.

## 7.4.3.0.0
* Certified with Mintegral SDK 7.4.3.

## 7.4.2.0.0
* Certified with Mintegral SDK 7.4.2.
* Updated minimum Xcode requirement to 14.1.

## 7.4.1.0.0
* Certified with Mintegral SDK 7.4.1.

## 7.3.9.0.0
* Certified with Mintegral SDK 7.3.9.
* Updated minimum Xcode requirement to 14.0.
* Fixed potential memory leaks by clearing delegates in `destroy:` method.   

## 7.3.8.0.0
* Certified with Mintegral SDK 7.3.8.

## 7.3.7.0.0
* Certified with Mintegral SDK 7.3.7.

## 7.3.6.0.0
* Certified with Mintegral SDK 7.3.6.

## 7.3.5.0.0
* Certified with Mintegral SDK 7.3.5.
* Remove the `privacySettingForSelector:fromParameters:` function and call privacy methods directly.
* Now requires MAX SDK version 6.14.0 or higher. 

## 7.3.4.0.2
* Update to use `MTGNewInterstitialBidAdManager` and `MTGNewInterstitialAdManager` in lieu of deprecated APIs `MTGBidInterstitialVideoAdManager` and `MTGInterstitialVideoAdManager`, respectively.

## 7.3.4.0.1
* Pass in extra data for signal collection.

## 7.3.4.0.0
* Certified with Mintegral SDK 7.3.4.

## 7.3.3.0.0
* Certified with Mintegral SDK 7.3.3.

## 7.3.1.0.1
* Pass in extra data for signal collection.

## 7.3.1.0.0
* Certified with Mintegral SDK 7.3.1.

## 7.3.0.0.0
* Certified with Mintegral SDK 7.3.0.

## 7.2.9.0.1
* Add COPPA support.

## 7.2.9.0.0
* Certified with Mintegral SDK 7.2.9.

## 7.2.8.0.1
* Update to use `[MAAdapterError errorWithCode:errorString:thirdPartySdkErrorCode:thirdPartySdkErrorMessage:]` to avoid crashes with AppLovin SDK 11.4.1 and earlier.

## 7.2.8.0.0
* Certified with Mintegral SDK 7.2.8.

## 7.2.7.0.0
* Certified with Mintegral SDK 7.2.7.

## 7.2.6.0.1
* Support for native ads in external plugins (e.g. React Native).

## 7.2.6.0.0
* Certified with Mintegral SDK 7.2.6.

## 7.2.5.0.0
* Certified with Mintegral SDK 7.2.5.
* Disable bitcode, as Apple deprecated it in Xcode 14 (https://developer.apple.com/documentation/xcode-release-notes/xcode-14-release-notes).

## 7.2.4.0.1
* Add support for native ad view ads.
* Add additional details for ad display failures. 

## 7.2.4.0.0
* Certified with Mintegral SDK 7.2.4.

## 7.2.3.0.1
* Add support for app open ads.

## 7.2.3.0.0
* Certified with Mintegral SDK 7.2.3.

## 7.2.1.0.1
* Remove `-[MTGBidInterstitialVideoAdManager isVideoReadyToPlayWithPlacementId:unitId:]` and `-[MTGBidRewardAdManager isVideoReadyToPlayWithPlacementId:unitId:]` checks for interstitial and rewarded bidding ads.

## 7.2.1.0.0
* Certified with Mintegral SDK 7.2.1.

## 7.1.9.0.0
* Certified with Mintegral SDK 7.1.9.0.

## 7.1.8.0.0
* Certified with Mintegral SDK 7.1.8.0.

## 7.1.7.0.2
* Add support for returning the main image asset in `MANativeAd` for native ads.

## 7.1.7.0.1
* Add `kMTGErrorCodeSocketIO` error code to error mapping.

## 7.1.7.0.0
* Certified with Mintegral SDK 7.1.7.0.
* Silence API deprecation warnings.

## 7.1.6.0.0
* Certified with Mintegral SDK 7.1.6.0.

## 7.1.5.0.1
* Map Mintegral image url empty error to MAX internal error.

## 7.1.5.0.0
* Certified with Mintegral SDK 7.1.5.0.
* Distribute adapter as an XCFramework.

## 7.1.4.0.0
* Certified with Mintegral SDK 7.1.4.0.

## 7.1.3.0.1
* Update ad display failed error code.

## 7.1.3.0.0
* Certified with Mintegral SDK 7.1.3.
* Record native ad impression on callback `-[MTGMediaView nativeAdImpressionWithType:mediaView:]` as well.

## 7.1.2.0.1
* Remove check for manual native ad assets.

## 7.1.2.0.0
* Certified with Mintegral SDK 7.1.2.

## 7.1.0.0.1
* Add support for passing in a presenting view controller.

## 7.1.0.0.0
* Certified with Mintegral SDK 7.1.0.

## 7.0.4.0.2
* Update open source versions to allow compilation with AppLovin SDK v11.0.0+.
* Consolidate Mintegral SDK dependencies to `MintegralAdSDK`.

## 7.0.4.0.1
* Properly destroy native ad.

## 7.0.4.0.0
* Certified with Mintegral SDK 7.0.4.
* Add support for native ads.

## 7.0.2.0.0
* Certified with Mintegral SDK 7.0.2.

## 6.9.4.0.0
* Certified with Mintegral SDK 6.9.4.0.

## 6.9.1.0.0
* Certified with Mintegral SDK 6.9.1.0.
* Update podspec to use `pod_target_xcconfig` over the deprecated `xcconfig`.

## 6.8.0.0.0
* Certified with Mintegral SDK 6.8.0.0.

## 6.7.9.0.0
* Certified with Mintegral SDK 6.7.9.0.

## 6.7.7.0.0
* Certified with Mintegral SDK 6.7.7.0.
* Update podspec source from bintray to S3.

## 6.7.6.0.0
* Certified with Mintegral SDK 6.7.6.0.

## 6.7.5.0.1
* Add support for passing creative id to SDK (supported in iOS SDK 6.15.0+).
* Add support to pass 3rd-party error code and description to SDK.

## 6.7.5.0.0
* Certified with Mintegral SDK 6.7.5.0.

## 6.7.4.0.0
* Certified with Mintegral SDK 6.7.4.0.

## 6.7.3.0.0
* Certified with Mintegral SDK 6.7.3.0.

## 6.7.2.0.0
* Certified with Mintegral SDK 6.7.2.0.

## 6.7.1.0.0
* Certified with Mintegral SDK 6.7.1.0.

## 6.7.0.0.0
* Certified with Mintegral SDK 6.7.0.0.

## 6.6.9.0.0
* Certified with Mintegral SDK 6.6.9.0.

## 6.6.8.0.0
* Certified with Mintegral SDK 6.6.8.0.

## 6.6.6.0.0
* Certified with Mintegral SDK 6.6.6.0.
* Re-pushing Mintegral Adapter with Mintegral SDK 6.6.6.0.
* Update 7000000 version check to 6140000.
* Update initialization log.

## 6.4.1.0.1
* Added support for Mintegral's placement id.

## 6.4.1.0.0
* Certified with Mintegral SDK 6.4.1.0.
* Removed the i386 slice. Adapter will no longer work on 32-bit simulators.

## 6.4.0.0.1
* Update 70000 version check to 7000000.

## 6.4.0.0.0
* Certified with Mintegral SDK 6.4.0.0.

## 6.3.7.0.0
* Certified with Mintegral SDK 6.3.7.0.

## 6.3.5.0.0
* Certified with Mintegral SDK 6.3.5.0.

## 6.3.3.0.7
* Fix incorrect adapter version returned by the adapter.

## 6.3.3.0.6
* Updated to not set privacy settings if nil.

## 6.3.3.0.5
* Roll back privacy changes.

## 6.3.3.0.4
* Fix versioning.

## 6.3.3.0.3
* Fix versioning.

## 6.3.3.0.2
* Updated to not set privacy settings if nil.

## 6.3.3.0.1
* Actually certify with Mintegral SDK 6.3.3.0.

## 6.3.3.0.0
* Certified with Mintegral SDK 6.3.3.0.

## 6.3.2.0.0
* Certified with Mintegral SDK 6.3.2.0.
* Added `[MTGSDK sdkVersion]` to retrieve Mintegral SDK version.

## 6.2.0.0.0
* Certified with Mintegral SDK 6.2.0.0.

## 6.1.3.0.0
* Certified with Mintegral SDK 6.1.3.0.

## 6.1.2.0.0
* Certified with Mintegral SDK 6.1.2.0.

## 6.1.0.0.0
* Certified with Mintegral SDK 6.1.0.0.

## 6.0.0.0.0
* Certified with Mintegral SDK 6.0.0.0.
