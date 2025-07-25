# Changelog

## 7.15.1.0
* Certified with Yandex SDK 7.15.1.

## 7.15.0.0
* Certified with Yandex SDK 7.15.0.

## 7.14.1.0
* Certified with Yandex SDK 7.14.1.

## 7.14.0.0
* Certified with Yandex SDK 7.14.0.
* Requires minimum AppLovin MAX SDK version be 11.4.0.
* Updated ad display failed error code.

## 7.13.0.0
* Certified with Yandex SDK 7.13.0.

## 7.12.3.0
* Certified with Yandex SDK 7.12.3.

## 7.12.2.1
* Add support for [adaptive banners](https://developers.applovin.com/en/max/ios/ad-formats/banner-and-mrec-ads#adaptive-banners) & inline adaptive ads in both [banners](https://developers.applovin.com/en/max/ios/ad-formats/banner-and-mrec-ads#inline-adaptive-banners) and [MRECs](https://developers.applovin.com/en/max/ios/ad-formats/banner-and-mrec-ads#inline-adaptive-mrecs). Requires AppLovin MAX SDK 13.2.0 or higher.

## 7.12.2.0
* Certified with Yandex SDK 7.12.2.
* Updated `YMABidderTokenLoader` usage to recommended initializer with mediation name.

## 7.12.1.0
* Certified with Yandex SDK 7.12.1.

## 7.12.0.0
* Certified with Yandex SDK 7.12.0.

## 7.11.1.0
* Certified with Yandex SDK 7.11.1.

## 7.11.0.0
* Certified with Yandex SDK 7.11.0.

## 7.10.2.0
* Certified with Yandex SDK 7.10.2.

## 7.10.1.0
* Certified with Yandex SDK 7.10.1.
* Updated minimum Xcode requirement to 16.0 to match Yandex SDK.

## 7.10.0.1
* Corrected certification for Yandex SDK 7.10.0.

## 7.10.0.0
* Certified with Yandex SDK 7.10.0.

## 7.8.0.0
* Certified with Yandex SDK 7.8.0.

## 7.5.0.3
* Add support for native ads in external plugins (e.g. React Native / Flutter).

## 7.5.0.2
* Add support for native ads.
* Removed exception throwing if unable to map ad format to that of the network's.

## 7.5.0.1
* Add back x86_64 simulator slice to match Yandex SDK.

## 7.5.0.0
* Certified with Yandex SDK 7.5.0.

## 7.4.0.0
* Certified with Yandex SDK 7.4.0.

## 7.0.1.0
* Certified with Yandex SDK 7.0.1.

## 7.0.0.0
* Certified with Yandex SDK 7.0.0.
* Update to use new APIs for signal collection and SDK version retrieval.
* Update to use new impression callback, `didTrackImpressionWith:`, for rewarded ads.
* Remove deprecated callbacks `didStartRewardedAdVideo` and `didCompleteRewardedAdVideo`.
* Updated minimum Xcode requirement to 15.0.

## 6.1.0.3
* Specified compatible version of Yandex dependency for republished SDK 6.1.0: VGSLCommonCore and VGSLNetworking (2.3.0).

## 6.1.0.2
* Specified compatible versions of Yandex dependencies: DivKit (28.4.0) and VGSLBase (2.2).

## 6.1.0.1
* Addressed an issue where fullscreen ad callbacks were not being invoked.

## 6.1.0.0
* Certified with Yandex SDK 6.1.0.

## 6.0.0.0
* Certified with Yandex SDK 6.0.0.
* Updated the minimum required iOS version to 13.0 to match Yandex SDK.

## 5.9.1.0
* Certified with Yandex SDK 5.9.1.

## 5.9.0.0
* Certified with Yandex SDK 5.9.0.

## 5.8.0.0
* Certified with Yandex SDK 5.8.0.
* Fixed potential memory leaks by clearing delegates in `destroy:` method.
* Updated minimum Xcode requirement to 14.1.

## 5.7.0.0
* Certified with Yandex SDK 5.7.0.

## 5.6.0.0
* Certified with Yandex SDK 5.6.0.
* Remove the `privacySettingForSelector:fromParameters:` function and call privacy methods directly.
* Now requires MAX SDK version 6.14.0 or higher. 

## 5.5.0.0
* Certified with Yandex SDK 5.5.0.

## 5.4.0.1
* Remove `consentDialogState` guard.

## 5.4.0.0
* Certified with Yandex SDK 5.4.0.

## 5.3.1.1
* Update to use `+[MAAdapterError errorWithCode:errorString:thirdPartySdkErrorCode:thirdPartySdkErrorMessage:]` to avoid crashes with AppLovin SDK 11.4.1 and earlier.

## 5.3.1.0
* Certified with Yandex SDK 5.3.1.
* Disable bitcode, as Apple deprecated it in Xcode 14 (https://developer.apple.com/documentation/xcode-release-notes/xcode-14-release-notes).
* Updated minimum Xcode requirement to 14.0.
* Add additional details for ad display failures. 

## 5.2.1.0
* Certified with Yandex SDK 5.2.1.

## 5.2.0.0
* Certified with Yandex SDK 5.2.0.

## 5.1.0.0
* Certified with Yandex SDK 5.1.0.
* Add bidding support.
* Update click callback for ads.
* Distribute adapter as an XCFramework.
* Silence API deprecation warnings.

## 4.4.2.3
* Update ad display failed error code.

## 4.4.2.2
* Add support for passing in a presenting view controller.

## 4.4.2.1
* Update open source versions to allow compilation with AppLovin SDK v11.0.0+.
* Add impression callback for ad view ads.

## 4.4.2.0
* Certified with Yandex SDK 4.4.2.

## 4.4.1.0
* Certified with Yandex SDK 4.4.1.

## 4.3.0.0
* Certified with Yandex SDK 4.3.0.
* Update and remove deprecated API usages.

## 2.20.0.1
* Update podspec source from bintray to S3.
* Update podspec to use `pod_target_xcconfig` over the deprecated `xcconfig`.

## 2.20.0.0
* Certified with Yandex SDK 2.20.0.
* Add support to pass 3rd-party error code and description to SDK.

## 2.19.0.1
* Only set user consent flag if GDPR applies.

## 2.19.0.0
* Certified with Yandex SDK 2.19.0.

## 2.18.0.1
* Removed the i386 slice. Adapter will no longer work on 32-bit simulators.
* Update 7000000 version check to 6140000.

## 2.18.0.0
* Certified with Yandex SDK 2.18.0.

## 2.17.0.2
* Update 70000 version check to 7000000.

## 2.17.0.1
* Add display callbacks for test mode interstitial and rewarded ads.

## 2.17.0.0
* Certified with Yandex SDK 2.17.0.

## 2.15.4.4
* Fix incorrect adapter version returned by the adapter.

## 2.15.4.3
* Updated to not set privacy settings if nil.

## 2.15.4.2
* Roll back privacy settings.

## 2.15.4.1
* Updated to not set privacy settings if nil.

## 2.15.4.0
* Certified with Yandex SDK 2.15.4.
* Add custom parameters in ad requests as requested by Yandex.
* Add new `didTrackAdapterImpression:` for tracking interstitial and rewarded ad impressions.
* Remove tracking impressions in original fullscreen `didAppear:` methods. 

## 2.14.0.1
* Fix adapter versioning.

## 2.14.0.0
* Certified with Yandex SDK 2.14.0.
* Add configuration of rewards from server parameters.

## 2.13.3.0
* Certified with Yandex SDK 2.13.3.

## 2.13.2.0
* Initial commit.
