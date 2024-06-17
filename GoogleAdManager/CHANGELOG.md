# Changelog

## 11.6.0.0
* Certified with GoogleAdManager SDK 11.6.0.

## 11.5.0.0
* Certified with GoogleAdManager SDK 11.5.0.

## 11.4.0.0
* Certified with GoogleAdManager SDK 11.4.0.
* Updated minimum Xcode requirement to 15.0.

## 11.3.0.0
* Certified with GoogleAdManager SDK 11.3.0.

## 11.2.0.1
* Added Privacy Manifest defining use of NSUserDefaults.
* Remove deprecated callbacks `didStartRewardedAdVideo`, `didCompleteRewardedAdVideo`, `didStartRewardedInterstitialAdVideo` and `didCompleteRewardedInterstitialAdVideo`.

## 11.2.0.0
* Certified with GoogleAdManager SDK 11.2.0.

## 11.1.0.0
* Certified with GoogleAdManager SDK 11.1.0.

## 11.0.1.0
* Certified with Google SDK 11.0.1 and updated to use new Google SDK APIs.
* Updated minimum Xcode requirement to 15.1.
* Updated minimum iOS version to 12.0.
* Improve error handling.

## 10.14.0.0
* Certified with GoogleAdManager SDK 10.14.0.

## 10.13.0.0
* Certified with GoogleAdManager SDK 10.13.0.

## 10.12.0.0
* Certified with GoogleAdManager SDK 10.12.0.

## 10.11.0.0
* Certified with GoogleAdManager SDK 10.11.0.

## 10.10.0.0
* Certified with GoogleAdManager SDK 10.10.0.

## 10.9.0.0
* Certified with GoogleAdManager SDK 10.9.0.
* Updated minimum Xcode requirement to 14.1.
* Fix deprecation warnings regarding `sdkVersion` and `tagForChildDirectedTreatment`.
* Updated the minimum required iOS version to 11.0 to match GoogleAdManager SDK. 

## 10.8.0.0
* Certified with GoogleAdManager SDK 10.8.0.

## 10.7.0.0
* Certified with GoogleAdManager SDK 10.7.0.
* Updated minimum Xcode requirement to 14.0.

## 10.6.0.1
* Update CCPA state if granted mid-session.
* Fixed potential memory leaks by clearing delegates in `destroy:` method.   

## 10.6.0.0
* Certified with GoogleAdManager SDK 10.6.0.

## 10.5.0.0
* Certified with GoogleAdManager SDK 10.5.0.

## 10.4.0.0
* Certified with GoogleAdManager SDK 10.4.0.
* Remove the `privacySettingForSelector:fromParameters:` function and call privacy methods directly.
* Now requires MAX SDK version 6.14.0 or higher. 
* Clean up `prepareViewForInteraction:` implementation.
 
## 10.3.0.2
* Add support for native ads in external plugins (e.g. React Native).

## 10.3.0.1
* Remove client-side setting of test device identifiers.

## 10.3.0.0
* Certified with GoogleAdManager SDK 10.3.0.

## 10.2.0.1
* Add support for custom adaptive banner widths.

## 10.2.0.0
* Certified with GoogleAdManager SDK 10.2.0.

## 10.1.0.1
* Adding back support for iOS 10.

## 10.1.0.0
* Certified with GoogleAdManager SDK 10.1.0.

## 9.14.0.2
* Add support for star ratings in manual native ads.

## 9.14.0.1
* Update to use `[MAAdapterError errorWithCode:errorString:thirdPartySdkErrorCode:thirdPartySdkErrorMessage:]` to avoid crashes with AppLovin SDK 11.4.1 and earlier.

## 9.14.0.0
* Certified with GoogleAdManager SDK 9.14.0.

## 9.13.0.0
* Certified with GoogleAdManager SDK 9.13.0.
* Disable bitcode, as Apple deprecated it in Xcode 14 (https://developer.apple.com/documentation/xcode-release-notes/xcode-14-release-notes).
* Add additional details for ad display failures.

## 9.11.0.5
* Fix non-native ad view related buttons becoming unclickable under custom native ad view. Please visit our updated [integration steps](https://dash.applovin.com/documentation/mediation/ios/ad-formats/native-manual#bind-ui-components) for further details.

## 9.11.0.4
* Remove redundant client side check for setting user consent.

## 9.11.0.3
* Add ability to set [publisher provided id](https://support.google.com/admanager/answer/2880055) via local extra parameters by calling `setLocalExtraParameterForKey: @"ppid" value: NSString`.

## 9.11.0.2
* Fix UI methods being called on background thread.

## 9.11.0.1
* Certified with GoogleAdManager SDK 9.11.0.1.

## 9.11.0.0
* Certified with GoogleAdManager SDK 9.11.0.

## 9.10.0.1
* Fix adapter open source compilation.

## 9.10.0.0
* Certified with GoogleAdManager SDK 9.10.0.

## 9.9.0.2
* Add support for `bannerViewDidRecordClick` callback.

## 9.9.0.1
* Add support for app open ads.

## 9.9.0.0
* Certified with GoogleAdManager SDK 9.9.0.

## 9.8.0.1
* Fix impression tracking for fullscreen ads.

## 9.8.0.0
* Certified with GoogleAdManager SDK 9.8.0.

## 9.7.0.0
* Certified with GoogleAdManager SDK 9.7.0.
* Use local scope copy of native ad while preparing view.

## 9.6.0.1
* Add support for returning the main image asset in `MANativeAd` for native ads.

## 9.6.0.0
* Certified with GoogleAdManager SDK 9.6.0.
* Silence API deprecation warnings.

## 9.5.0.0
* Certified with GoogleAdManager SDK 9.5.0.

## 9.4.0.3
* Add support for providing native media content aspect ratio in `MANativeAdView`.
* Distribute adapter as an XCFramework.

## 9.4.0.2
* Update ad display failed error code.

## 9.4.0.1
* Add ability to set [custom targeting](https://developers.google.com/ad-manager/mobile-ads-sdk/android/targeting#custom_targeting) via local extra parameters by calling `setLocalExtraParameterForKey: "custom_targeting" value: NSDictionary<NSString *, NSString *>`.

## 9.4.0.0
* Certified with GoogleAdManager SDK 9.4.0.

## 9.3.0.2
* Add ability to set [content mapping URLs](https://support.google.com/admanager/answer/11050896) via local extra parameters by calling `setLocalExtraParameterForKey: "google_content_url" value: NSString` or set multiple URLs by calling `setLocalExtraParameterForKey: "google_neighbouring_content_url_strings" value: NSArray<NSString *>`.

## 9.3.0.1
* Remove check for manual native ad assets.

## 9.3.0.0
* Certified with GoogleAdManager SDK 9.3.0.

## 9.2.0.1
* Add ability to set [maximum ad content rating](https://support.google.com/admanager/answer/9467073) via local extra parameters by calling `setLocalExtraParameterForKey: "google_max_ad_content_rating" value: NSString`.

## 9.2.0.0
* Certified with GoogleAdManager SDK 9.2.0.

## 9.1.0.0
* Certified with Google SDK 9.1.0.

## 8.13.0.8
* Add support for passing in a presenting view controller.

## 8.13.0.7
* Fix AdChoices `localExtraParameters` crash. Publishers can set a custom placement on AppLovin SDKs 11.0.0+ and the placement is defaulted to the top right corner otherwise.

## 8.13.0.6
* Add support for sending ad size information for adview ads. This value can be retrieved in the `didLoad()` callback using the `size` property from `MAAd.h` available in MAX SDK v11.2.0.

## 8.13.0.5
* Add support for custom [AdChoices placements](https://developers.google.com/admob/ios/api/reference/Enums/GADAdChoicesPosition.html), which publishers can set by calling `setLocalExtraParameterForKey("gam_ad_choices_placement", GADAdChoicesPosition)` on the `MANativeAdLoader` instance.

## 8.13.0.4
* Fix additional potential UI API being called on a background thread for native ads. 

## 8.13.0.3
* Update open source versions to allow compilation with AppLovin SDK v11.0.0+.
* Fix potential UI API being called on a background thread for native ads.

## 8.13.0.2
* Properly destroy native ad.

## 8.13.0.1
* Add support for native custom ads and updated native template ad support.
* Remove bidding and signal collection logic from adapter.

## 8.13.0.0
* Certified with GoogleAdManager SDK 8.13.0.
* Fix adapter deprecation warnings.

## 8.12.0.0
* Certified with GoogleAdManager SDK 8.12.0.

## 8.11.0.1
* Add `adDidRecordClick` callback for fullscreen ads.

## 8.11.0.0
* Certified with GoogleAdManager SDK 8.11.0.

## 8.10.0.1
* Initial support for true native ads.

## 8.10.0.0
* Certified with GoogleAdManager SDK 8.10.0.

## 8.9.0.0
* Certified with GoogleAdManager SDK 8.9.0.

## 8.8.0.2
* Add `placement_req_id` to network extras for all ad requests.

## 8.8.0.1
* Add support for rewarded interstitial ads.

## 8.8.0.0
* Certified with GoogleAdManager SDK 8.8.0.

## 8.7.0.0
* Certified with GoogleAdManager SDK 8.7.0.

## 8.6.0.1
* Update bidding APIs.

## 8.6.0.0
* Certified with GoogleAdManager SDK 8.6.0.

## 8.5.0.0
* Certified with GoogleAdManager SDK 8.5.0.

## 8.4.0.1
* Remove expired bids after set amount of time.

## 8.4.0.0
* Certified with GoogleAdManager SDK 8.4.0.
* Update podspec to use `pod_target_xcconfig` over the deprecated `xcconfig`.

## 8.3.0.0
* Certified with GoogleAdManager SDK 8.3.0.

## 8.2.0.1
* Certified with GoogleAdManager SDK 8.2.0.1.
* NOTE: This adapter version is the same as the SDK pod version, because Google released a one-off update with four version numbers.

## 8.2.0.0
* Certified with GoogleAdManager SDK 8.2.0.

## 8.1.0.1
* Add support for bidding.

## 8.1.0.0
* Certified with GoogleAdManager SDK 8.1.0.

## 8.0.0.0
* Certified with Google SDK 8.0.0.
* Remove click tracking for interstitial ads.
* Update podspec source from bintray to S3.

## 7.69.0.2
* Add support for creative id for banner native.

## 7.69.0.1
* Add support for passing creative ID to MAX SDK (supported in iOS SDK 6.15.0+).
* Add support to pass 3rd-party error code and description to SDK.

## 7.69.0.0
* Certified with Google SDK 7.69.0. This version of AdMob is only compatible with Firebase 7.0.0+.

## 7.67.1.5
* Add support for `adViewDidRecordImpression` callback.

## 7.67.1.4
* Add support for adaptive banners.

## 7.67.1.3
* Only set user consent flag if GDPR applies.

## 7.67.1.2
* Update native banners to use custom templates passed down from backend instead of hardcoding templates.

## 7.67.1.1
* Downgrade to Google SDK 7.66.0. This is due to 7.67.x not being compatible with latest release of Firebase 7.0.0 (which has not been released on Unity as well).

## 7.67.1.0
* Certified with GoogleAdManager SDK 7.67.1.

## 7.66.0.2
* Add checks for required native ad assets (headline, body, images, icon and CTA).

## 7.66.0.1
* Add support for vertical template native banners.

## 7.66.0.0
* Certified with GoogleAdManager SDK 7.66.0.

## 7.65.0.0
* Certified with GoogleAdManager SDK 7.65.0.
* Removed the i386 slice. Adapter will no longer work on 32-bit simulators.
* Update 7000000 version check to 6140000.

## 7.64.0.2
* Update 70000 version check to 7000000.

## 7.64.0.1
* Set rewarded ad to `nil` in adapter `destroy` method.
* Update 61400 version check to 70000.

## 7.64.0.0
* Certified with Google Ad Manager SDK 7.64.0.
* Update deprecated Google Ad Manager SDK version retrieval.

## 7.63.0.0
* Certified with Google Ad Manager SDK 7.63.0.

## 7.62.0.5
* Fix incorrect adapter version returned by the adapter.

## 7.62.0.4
* Updated to not set privacy settings if nil.

## 7.62.0.3
* Roll back privacy changes.

## 7.62.0.2
* Updated to not set privacy settings if nil.

## 7.62.0.1
* Fix versioning.

## 7.62.0.0
* Certified with Google Ad Manager SDK 7.62.0.

## 7.61.0.1
* Add support for native ad views.

## 7.61.0.0
* Certified with Google Ad Manager SDK 7.61.0.

## 7.60.0.0
* Certified with Google Ad Manager SDK 7.60.0.

## 7.59.0.0
* Certified with Google Ad Manager SDK 7.59.0.

## 7.58.0.0
* Certified with Google Ad Manager SDK 7.58.0.

## 7.57.0.1
* Fix bug where mute state was not being applied.

## 7.57.0.0
* Certified with Google Ad Manager SDK 7.57.0.

## 7.55.1.0
* Certified with Google Ad Manager SDK 7.55.1.
* Fix CCPA support - requires AppLovin SDK 6.11.0 to compile.

## 7.55.0.0
* Certified with Google Ad Manager SDK 7.55.0.

## 7.54.0.0
* Certified with Google Ad Manager SDK 7.54.0.

## 7.53.1.1
* Updated deprecated API usages.

## 7.53.1.0
* Certified with Google Ad Manager SDK 7.53.1.

## 7.51.0.1
* Add support for CCPA.

## 7.51.0.0
* Initial commit.
