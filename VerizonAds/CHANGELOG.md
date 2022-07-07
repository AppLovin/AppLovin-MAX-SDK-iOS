# Changelog

## 2.0.0.6
* Remove duplicate `prepareView` call.

## 2.0.0.5
* Add support for passing local parameter "is_location_collection_enabled" to set `[[YASAds sharedInstance] setLocationAccessMode: ...]` 

## 2.0.0.4
* Add support for returning the main image asset in `MANativeAd` for native ads.

## 2.0.0.3
* Add support for IAB's TCFv2 GDPR consent string. Note that you must be on the AppLovin MAX SDK v11.4.2+ and use a TCFv2-compliant framework which stores the consent string in User Defaults via the `IABTCF_TCString` key to use this feature.

## 2.0.0.2
* Add support for clickability of video, image and icon components.
* Do not explicitly destroy Yahoo native ads, as it will clear previously-registered `UILabel`s and `UIButton`s.

## 2.0.0.1
* Fix native ads not tracking impressions properly.

## 2.0.0.0
* Certified with Yahoo Mobile SDK 1.0.0.
* Remove arm64 simulator slice which the Yahoo-Ads SDK does not support.

## 1.14.2.10
* Add support for providing native media content aspect ratio in `MANativeAdView`.
* Distribute adapter as an XCFramework.

## 1.14.2.9
* Update ad display failed error code.

## 1.14.2.8
* Add support for tracking impressions for all ad formats.

## 1.14.2.7
* Add support for tracking banner ad impressions.

## 1.14.2.6
* Remove check for manual native ad assets.

## 1.14.2.5
* Remove support for `consent_string`.

## 1.14.2.4
* Add support for passing in a presenting view controller.

## 1.14.2.3
* Add support for IAB's CCPA Privacy String.

## 1.14.2.2
* Add support for native ads.

## 1.14.2.1
* Use `[[VASAds sharedInstance] biddingTokenTrimmedToSize: 4000]` for signal collection.
* Update open source versions to allow compilation with AppLovin SDK v11.0.0+.

## 1.14.2.0
* Certified with VerizonAds SDK 1.14.2.

## 1.14.1.2
* Update signal collection method.

## 1.14.1.1
* Add support for rewarded ads.
* Add support for passing creative id to SDK (supported in iOS SDK 6.15.0+).

## 1.14.1.0
* Certified with VerizonAds SDK 1.14.1.

## 1.14.0.0
* Certified with VerizonAds SDK 1.14.0.
* Update privacy setting calls to use `VASDataPrivacyBuilder`.

## 1.9.0.1
* Update podspec source from bintray to S3.
* Update podspec to use `pod_target_xcconfig` over the deprecated `xcconfig`.

## 1.9.0.0
* Certified with VerizonAds SDK 1.9.0.
* Add support to pass 3rd-party error code and description to SDK.

## 1.8.1.0
* Certified with VerizonAds SDK 1.8.1.
* Remove deprecated cache delegate functions.

## 1.8.0.0
* Certified with VerizonAds SDK 1.8.0.

## 1.7.1.1
* Removed the i386 slice. Adapter will no longer work on 32-bit simulators.
* Update 7000000 version check to 6140000.
* Update initialization log.

## 1.7.1.0
* Certified with VerizonAds SDK 1.7.1 which addresses IPA upload issues.

## 1.7.0.2
* Certify against Verizon's specific static SDK (`Verizon-Ads-StandardEdition-Static`) instead.  

## 1.7.0.1
* Update 70000 version check to 7000000.

## 1.7.0.0
* Certified with VerizonAds SDK 1.7.0.

## 1.6.0.4
* Fix incorrect adapter version returned by the adapter.

## 1.6.0.3
* Updated to not set privacy settings if nil.

## 1.6.0.2
* Roll back privacy changes.

## 1.6.0.1
* Updated to not set privacy settings if nil.
* Extract bidding token version into a constant.

## 1.6.0.0
* Certified with VerizonAds SDK 1.6.0.

## 1.5.0.2
* Update signal collection per VerizonAd's suggestion.

## 1.5.0.1
* Fixed a crash when banner ad is clicked.

## 1.5.0.0
* Certified with SDK 1.5.0.
* Added support for new header bidding APIs.

## 1.4.0.0
* Updated logs to differentiate ad view formats.
* Certified with SDK 1.5.0 (finally removes the `UIImagePickerController` reference).

## 1.3.0.0
* Certified with SDK 1.3.0 (with privacy API changes).
* Remove support for passing in whether GDPR applies or not.

## 1.2.1.0
* Certified with SDK 1.2.1.

## 1.2.0.1
* Updated how Verizon Ads SDK version is collected.

## 1.2.0.0
* Certified with SDK 1.2.0.

## 1.1.4.0
* Certified with SDK 1.1.4.

## 1.1.3.0
* Certified with SDK 1.1.3.

## 1.1.2.1
* Add support for initialization status.

## 1.1.2.0
* Initial commit.
