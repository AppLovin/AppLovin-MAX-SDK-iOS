# Changelog

## 4.1.0.1
* Fix init failure from `[mediationMetaData setValue: ADAPTER_VERSION forKey: @"adapter_version"];`.

## 4.1.0.0
* Certified with UnityAds SDK 4.1.0.
* Remove checks for UnityAds SDK being initialized before loading ads.

## 4.0.1.3
* Add support for COPPA. 

## 4.0.1.2
* Fix privacy consent by using `commit()` after each value is set to the metadata.

## 4.0.1.1
* Add support for passing in a presenting view controller.

## 4.0.1.0
* Certified with UnityAds SDK 4.0.1.

## 4.0.0.1
* Update open source versions to allow compilation with AppLovin SDK v11.0.0+.
* Verify UnityAds SDK is initialized before loading ads.

## 4.0.0.0
* Certified with UnityAds SDK 4.0.0.
* Update to use consolidated `initialize()` API.

## 3.7.5.1
* Remove setting of bidding meta data.

## 3.7.5.0
* Certified with UnityAds SDK 3.7.5.

## 3.7.2.0
* Certified with UnityAds SDK 3.7.2.

## 3.7.1.1
* Fix signal collection by setting bidding meta data before initialization based on server parameters.

## 3.7.1.0
* Updated to use new APIs introduced in UnityAds SDK 3.7.0.
* Removed deprecated APIs and router.
* Update podspec to use `pod_target_xcconfig` over the deprecated `xcconfig`.

## 3.6.0.1
* Update podspec source from bintray to S3.
* Update bidding APIs to include a random ID.

## 3.6.0.0
* Add support for UnityAds interstitial and rewarded bidding.
* Add support to pass 3rd-party error code and description to SDK.

## 3.5.1.1
* Add support for Unity's new load delegate since old callbacks aren't called for some load errors.

## 3.5.1.0
* Certified with UnityAds SDK 3.5.1.
* Switched to Unity's new load API for interstitials and rewarded videos.
* Implemented Unity's new initialization delegate.

## 3.5.0.2
* Only set user consent flag if GDPR applies.

## 3.5.0.1
* Downgraded to UnityAds SDK 3.4.8.

## 3.5.0.0
* Certified with UnityAds SDK 3.5.0.

## 3.4.8.3
* Fix edge case where ad hidden callback was not fired if the ad experienced an error.

## 3.4.8.2
* Removed the i386 slice. Adapter will no longer work on 32-bit simulators.
* Update 7000000 version check to 6140000.
* Update initialization log.

## 3.4.8.1
* Update 70000 version check to 7000000.

## 3.4.8.0
* Certified with UnityAds SDK 3.4.8.

## 3.4.6.5
* Fix incorrect adapter version returned by the adapter.

## 3.4.6.4
* Updated to not set privacy settings if nil.

## 3.4.6.3
* Roll back privacy changes.

## 3.4.6.2
* Updated to not set privacy settings if nil.

## 3.4.6.1
* Fix versioning.

## 3.4.6.0
* Certified with UnityAds SDK 3.4.6.

## 3.4.2.2
* Fix ad display failed callback not firing in rare cases.
* Add placement ID to fullscreen ad load and display log messages.

## 3.4.2.1
* Fix CCPA support - requires AppLovin SDK 6.11.0 to compile.

## 3.4.2.0
* Certified with UnityAds SDK 3.4.2.

## 3.4.0.1
* Add support for CCPA.

## 3.4.0.0
* Certified with UnityAds SDK 3.4.0.

## 3.3.0.1
* Add support for UnityAds banners.

## 3.3.0.0
* Certified with UnityAds SDK 3.3.0.
* Updated the minimum required AppLovin SDK version to 6.5.0.

## 3.2.0.0
* Certified with UnityAds SDK 3.2.0.
* Add support for per-placement loading. Requires whitelisted game ID and 'enable_per_placement_load' server parameter set to true on initialize.

## 3.1.0.1
* Add support for initialization status.

## 3.1.0.0
* Certified with UnityAds SDK 3.1.0.
* Add Unity support for automatic dependency resolution. Please ensure that you are on the latest [AppLovin MAX Unity Plugin](https://bintray.com/applovin/Unity/applovin-max-unity-plugin).
* Add support for extra reward options.

## 3.0.3.0
* Certified with UnityAds SDK 3.0.3.

## 3.0.0.2
* Explicitly fail load when placements NO FILL instead of waiting to timeout.
* Use router for interstitial [AD LOADED] and rewarded video [AD DISPLAYED] callbacks.

## 3.0.0.1
* Update adapter logging.

## 3.0.0.0
* Initial commit.
