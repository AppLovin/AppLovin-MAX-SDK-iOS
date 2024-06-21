# Changelog

## 6.4.1.0.0
* Certified with HyprMX SDK 6.4.1.

## 6.4.0.0.0
* Certified with HyprMX SDK 6.4.0.
* Update to use new initialization and delegate APIs.
* Updated minimum Xcode requirement to 15.0.
* Updated the minimum required iOS version to 12.0 to match HyprMX SDK. 

## 6.3.0.1.1
* Added Privacy Manifest defining use of UserDefaults.
* Remove deprecated callbacks `didStartRewardedAdVideo` and `didCompleteRewardedAdVideo`.

## 6.3.0.1.0
* Certified with HyprMX SDK 6.3.0.1.

## 6.3.0.1
* Fully re-written in Swift.
* Updated minimum AppLovinSDK requirement to 12.0.0.
* Updated minimum iOS version to 11.0.

## 6.3.0.0
* Certified with HyprMX SDK 6.3.0.
* Updated minimum Xcode requirement to 14.1.
* Fixed potential memory leaks by clearing delegates in `destroy:` method.   

## 6.2.0.1
* Add support to set `ageRestrictedUser` on initialization.
* Remove the `ageRestrictedUser` check from user consent.

## 6.2.0.0
* Certified with HyprMX SDK 6.2.0.
* Updated podspec to use `HyprMX` instead of `HyprMX/Core`.
* Disable bitcode, as Apple deprecated it in Xcode 14 (https://developer.apple.com/documentation/xcode-release-notes/xcode-14-release-notes).
* Updated minimum Xcode requirement to 14.0.
* Add additional details for ad display failures. 

## 6.0.3.1
* Set consent based on a mix of 'hasUserConsent', 'ageRestrictedUser' and 'doNotSell' values.

## 6.0.3.0
* Certified with HyprMX SDK 6.0.3.

## 6.0.1.7
* Update consent status before collecting signal. 

## 6.0.1.6
* Add support to set `hasUserConsent` on initialization.
* Pass HyprMX error message for ad display errors.
* Distribute adapter as an XCFramework.
* Silence API deprecation warnings.

## 6.0.1.5
* Update ad display failed error code.

## 6.0.1.4
* Set GDPR consent status regardless of users' region.

## 6.0.1.3
* Remove setting GDPR consent status to `CONSENT_STATUS_UNKNOWN`.

## 6.0.1.2
* Add support for GDPR.

## 6.0.1.1
* Update open source versions to allow compilation with AppLovin SDK v11.0.0+.
* Add support for passing in a presenting view controller.

## 6.0.1.0
* Certified with HyprMX SDK 6.0.1.

## 6.0.0.1
* Add support for banners, leaders, MRECs.
* Better mapping of fullscreen ad display errors.

## 6.0.0.0
* Certified with HyprMX SDK 6.0.0.
* Update podspec to use `pod_target_xcconfig` over the deprecated `xcconfig`.

## 5.4.5.0
* Certified with HyprMX SDK 5.4.5.
* Fix memory leak with `initializationDelegate` since `+[MAAdapter destroy]` is not called for adapters used for initializing SDKs.
* Add support to pass 3rd-party error code and description to SDK.
* Update podspec source from bintray to S3.

## 5.4.3.2
* Added error code for when SDK is not initialized in `adNotAvailableForPlacement:` callback.

## 5.4.3.1
* Updated podspec to use `HyprMX/Core` instead of plain `HyprMx`.

## 5.4.3.0
* Certified with HyprMX SDK 5.4.3.

## 5.4.2.1
* Fix userID being null.

## 5.4.2.0
* Initial commit.
