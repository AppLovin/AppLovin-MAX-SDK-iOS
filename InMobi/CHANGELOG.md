# Changelog

## 10.0.1.1
* Fix interstitials not reporting creative id correctly.

## 10.0.1.0
* Certified with InMobi SDK 10.0.1.
* Update signal collection APIs.

## 9.2.1.1
* Update consent dictionary and API used to set GDPR info.
* Update GDPR before signal collection.

## 9.2.1.0
* Certified with InMobi SDK 9.2.1.
* Update podspec to use `pod_target_xcconfig` over the deprecated `xcconfig`.

## 9.1.7.0
* Certified with InMobi SDK 9.1.7.

## 9.1.5.0
* Certified with InMobi SDK 9.1.5.
* Update podspec source from bintray to S3.

## 9.1.1.1
* Add support for passing creative id to SDK (supported in iOS SDK 6.15.0+).
* Add support to pass 3rd-party error code and description to SDK.

## 9.1.1.0
* Certified with InMobi SDK 9.1.1.

## 9.1.0.1
* Only set user consent flag if GDPR applies.

## 9.1.0.0
* Certified with InMobi SDK 9.1.0.

## 9.0.7.9
* Update 7000000 version check to 6140000.
* Update initialization log.

## 9.0.7.8
* Update signal collection to fail early if InMobi SDK is not initialized successfully.
* Removed the i386 slice. Adapter will no longer work on 32-bit simulators.

## 9.0.7.7
* Fix delay caused by invalid placement identifier handling in signal collection.

## 9.0.7.6
* Update 70000 version check to 7000000.

## 9.0.7.5
* Fix incorrect adapter version returned by the adapter.

## 9.0.7.4
* Updated to not set privacy settings if nil.

## 9.0.7.3
* Roll back privacy changes.

## 9.0.7.2
* Update deprecated callbacks (`interstitial:didReceiveWithMetaInfo:`) for interstitial and rewarded ads.
* Updated to not set privacy settings if nil.

## 9.0.7.1
* Fix bidding for leaders by mapping "leaders" placement key to "banners" placement key. 

## 9.0.7.0
* Certified with SDK 9.0.7.
* Add support for bidding.

## 9.0.6.1
* Point to `InMobiSDK/Core`.

## 9.0.6.0
* Certified with SDK 9.0.6.
* Track initialization status with new initialization complete callback.

## 9.0.4.0
* Certified with SDK 9.0.4.

## 9.0.3.1
* Add support for medium rectangle ad views.

## 9.0.3.0
* Certified with SDK 9.0.3.

## 9.0.1.2
* Added banner display callback to `bannerDidFinishLoading:`.

## 9.0.1.1
* Moved interstitial and rewarded display callbacks from `interstitialWillPresent:` to `interstitialDidPresent:`.

## 9.0.1.0
* Certified with SDK 9.0.1.

## 9.0.0.0
* Certified with SDK 9.0.0.
* Removed unused server parameters.
* Updated the minimum required AppLovin SDK version to 6.5.0.
* Removed support for muting/un-muting of ads.

## 7.3.2.1
* Format `IM_GDPR_CONSENT_AVAILABLE` value to true/false.

## 7.3.2.0
* Certified with SDK 7.3.2.

## 7.3.1.1
* Uncertify  SDK 7.3.1, re-certify against SDK 7.2.9 due to `isReady` bug.

## 7.3.1.0
* Certified with SDK 7.3.1.
* Add support for initialization status.

## 7.2.9.0
* Add Unity support for automatic dependency resolution. Please ensure that you are on the latest [AppLovin MAX Unity Plugin](https://bintray.com/applovin/Unity/applovin-max-unity-plugin).
* Add support for extra reward options.

## 7.2.7.2
* Minor adapter improvements.

## 7.2.7.1
* Use `interstitialWillPresent:` instead of `interstitialDidPresent:` for impression tracking.

## 7.2.7.0
* Initial commit.
