# Changelog

## 6.10.6.2
* Add support for passing in a presenting view controller.

## 6.10.6.1
* Add missing call to configure rewards for rewarded ads.

## 6.10.6.0
* Certified with Vungle SDK 6.10.6.

## 6.10.5.2
* Update open source versions to allow compilation with AppLovin SDK v11.0.0+.
* Improve stability of banners.

## 6.10.5.1
* Add further support for ad muting.

## 6.10.5.0
* Certified with Vungle SDK 6.10.5.

## 6.10.4.0
* Certified with Vungle SDK 6.10.4.

## 6.10.3.0
* Certified with Vungle SDK 6.10.3 which fixes older SDKs' black screen on Xcode 13.

## 6.10.2.0
* Certified with Vungle SDK 6.10.2.
* Re-add new ad markup APIs.

## 6.10.1.3
* Downgrade certify version to 6.9.1 because Vungle 6.10.1 requires Xcode 12.5.
* Revert code changes from 6.10.1.0.

## 6.10.1.2
* Certified with Vungle SDK 6.10.1.
* Re-add new ad markup APIs.

## 6.10.1.1
* Downgrade certify version to 6.9.1 because Vungle's crash issues in 6.10.1.
* Revert code changes from 6.10.1.0.

## 6.10.1.0
* Certified with Vungle SDK 6.10.1.
* Add new ad markup APIs.

## 6.9.2.1
* Downgrade Vungle SDK to 6.8.1.

## 6.9.2.0
* Certified with Vungle SDK 6.9.2.
* Update podspec to use `pod_target_xcconfig` over the deprecated `xcconfig`.

## 6.8.1.5
* Fail ad display if Vungle returns error on `-[VungleSDK playAd:options:placementID:error:]`.

## 6.8.1.4
* Update podspec source from bintray to S3.
* Add handling for edge case load failures instead of waiting for MAX to time out the ad load.

## 6.8.1.3
* Add support for passing creative id to SDK (supported in iOS SDK 6.15.0+).
* Add support to pass 3rd-party error code and description to SDK.

## 6.8.1.2
* Only set `VunglePlayAdOptionKeyOrientations`  to landscape if the app is in landscape for fullscreen ads, as Vungle's SDK will rotate the host app to landscape if done for banners.

## 6.8.1.1
* Only set user consent flag if GDPR applies.

## 6.8.1.0
* Certified with Vungle SDK 6.8.1.
* Moved CIMP to `vungleAdViewedForPlacement`.
* Set `VunglePlayAdOptionKeyOrientations`  to landscape if the app is in landscape.

## 6.8.0.0
* Certified with Vungle SDK 6.8.0.
* Remove guard for setting mediation identifier (plugin name) for Vungle.

## 6.7.2.0
* Certified with Vungle SDK 6.7.2.

## 6.7.1.3
* Update MAX as plugin name.
* Removed the i386 slice. Adapter will no longer work on 32-bit simulators.
* Update 7000000 version check to 6140000.
* Update initialization log.

## 6.7.1.2
* Add support for bidding.

## 6.7.1.1
* Update 70000 version check to 7000000.

## 6.7.1.0
* Certified with Vungle SDK 6.7.1.

## 6.7.0.6
* Fix incorrect adapter version returned by the adapter.

## 6.7.0.5
* Updated to not set privacy settings if nil.

## 6.7.0.4
* Roll back privacy changes.

## 6.7.0.3
* Updated to not set privacy settings if nil.

## 6.7.0.2
* Fix versioning for Vungle adapter.

## 6.7.0.1
* Remove check for cached interstitial and rewarded ads before loading them (matching MoPub's logic to fix impression discrepancies). 

## 6.7.0.0
* Certified with Vungle SDK 6.7.0.
* Add support for CCPA.
* Click postbacks are now fired in realtime instead of at the end of the video.
* Show 728x90 leaders instead of 320x50 banners on iPads.
* Fix code inconsistency with other adapters.

## 6.5.3.0
* Certified with SDK 6.5.3.
* Disable auto refresh for banner and MREC ads.

## 6.5.2.4
* Incorrect adapter version fixed.

## 6.5.2.3
* Show 320x50 banners on tablets to fix resizing issues.

## 6.5.2.2
* Automatically fail ad loads if Vungle SDK is not initialized successfully yet to reduce crashes.

## 6.5.2.1
* Add support for banner ad views.

## 6.5.2.0
* Certified with SDK 6.5.2.
* Fixed a bug for MREC publishers where if a Vungle MREC is showing and a fullscreen Vungle ad failed to load, it would not fire the callback (waiting for the timeout instead).
* Correctly map `vungleAdPlayabilityUpdate:placementID:error:` where `isAdPlayable` is `NO` and `error` is `nil` to NO FILLs instead of unspecified errors (5200).

## 6.5.1.0
* Certified with SDK 6.5.1.
* Medium Rectangle Ad Views no longer work due to placement id error. 

## 6.4.6.1
* Add support for medium rectangle ad views.

## 6.4.6.0
* Certified with SDK 6.4.6.
* Change CIMP to `vungleDidShowAdForPlacementID`.
* Add support for mute configuration.

## 6.4.5.0
* Certified with SDK 6.4.5.
* Updated the minimum required AppLovin SDK version to 6.5.0.
* Removed support for muting/un-muting of ads.

## 6.4.3.0
* Certified with SDK 6.4.3.

## 6.3.2.3
* Add support for initialization status.

## 6.3.2.2
* Add Unity support for automatic dependency resolution. Please ensure that you are on the latest [AppLovin MAX Unity Plugin](https://bintray.com/applovin/Unity/applovin-max-unity-plugin).
* Add support for extra reward options.

## 6.3.2.1
* Update adapter logging.

## 6.3.2.0
* Initial commit.
