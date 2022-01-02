# Changelog

## x.x.x.x
* Update open source versions to allow compilation with AppLovin SDK v11.0.0+.

## 5.16.2.0
* Certified with MoPub SDK 5.16.2.
* Update podspec to use `pod_target_xcconfig` over the deprecated `xcconfig`.

## 5.15.0.0
* Certified with MoPub SDK 5.15.0.
* Add support for initialization status.
* Add support for passing creative id to SDK (supported in iOS SDK 6.15.0+).
* Add support to pass 3rd-party error code and description to SDK.
* Add support for non-rewarded errors from MoPub.
* Only set user consent flag if GDPR applies.
* Use `didTrackImpressionWithAdUnitID...` for ad displayed callbacks. 
* Add Swift 5 version to podspec.
* Bump minimum OS version to 10.0.
* Update podspec source from bintray to S3.

## 5.5.0.1
* Turn on verbose logging when in testing mode.
* Bundle MoPub's device-only SDK and not th pre-built SDK as the 4 architectures were not combined correctly, leading to the inability to upload to the App Store.

## 5.5.0.0
* Certified with MoPub SDK 5.5.0.

## 5.4.0.2
* iOS MoPub Unity will have mraid.js masked as mraid.js.no_compile.

## 5.4.0.1
* Match the `didStartRewardedAdVideo` callback with the `didCompleteRewardedAdVideo` callback.

## 5.4.0.0
* Initial commit.
* In our MoPub unitypackage, the provided MoPub SDK contains only two architectures: armv7 and arm64.
