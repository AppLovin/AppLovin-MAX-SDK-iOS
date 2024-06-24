# Changelog

## 3.0.2.0
* Certified with Verve SDK 3.0.2.

## 3.0.1.0
* Certified with Verve SDK 3.0.1.
* Updated the minimum required iOS version to 12.0 to match Verve SDK. 

## 3.0.0.1
* Downgrade Verve iOS SDK to v2.21.2 due to issues in v3.0.0, which includes the ATOM SDK, causing AppLovin INTER/RV ads to break. The ATOM SDK should be disabled if included manually.
* Updated minimum Xcode requirement to 15.0.

## 3.0.0.0
* Certified with Verve SDK 3.0.0.

## 2.21.2.0
* Certified with Verve SDK 2.21.2.
* Remove deprecated callbacks `didStartRewardedAdVideo` and `didCompleteRewardedAdVideo`.

## 2.21.1.0
* Certified with Verve SDK 2.21.1.
* Update mute setting API.
* Updated minimum iOS version to 11.0.

## 2.20.0.0
* Certified with Verve SDK 2.20.0.

## 2.19.0.0
* Certified with Verve SDK 2.19.0.
* Updated minimum Xcode requirement to 14.1.
* Fixed potential memory leaks by clearing delegates in `destroy:` method.   

## 2.18.1.1
* Add support for binary consent state as a fallback option if the TCFv2 GDPR consent string is not present in User Defaults. 

## 2.18.1.0
* Certified with Verve SDK 2.18.1.
* Remove unnecessary MAX SDK version check.

## 2.18.0.0
* Certified with Verve SDK 2.18.0.

## 2.17.0.0
* Certified with Verve SDK 2.17.0.

## 2.16.2.1
* Use new Swift bridging file and remove `HyBid-Swift.h`.

## 2.16.2.0
* Certified with Verve SDK 2.16.2.

## 2.16.1.3
* Remove `consentDialogState` guard.

## 2.16.1.2
* Disable bitcode, as Apple deprecated it in Xcode 14 (https://developer.apple.com/documentation/xcode-release-notes/xcode-14-release-notes).
* Update to use `+[MAAdapterError errorWithCode:errorString:thirdPartySdkErrorCode:thirdPartySdkErrorMessage:]` to avoid crashes with AppLovin SDK 11.4.1 and earlier.

## 2.16.1.1
* Update swift bridging file.

## 2.16.1.0
* Certified with Verve SDK 2.16.1.
* Add additional details for ad display failures. 

## 2.16.0.0
* Certified with Verve SDK 2.16.0.

## 2.15.0.0
* Certified with Verve SDK 2.15.0.

## 2.14.0.1
* Update consent status before collecting signal.

## 2.14.0.0
* Certified with Verve SDK 2.14.0.

## 2.13.1.0
* Certified with Verve SDK 2.13.1.

## 2.13.0.0
* Certified with Verve SDK 2.13.0.
* Distribute adapter as an XCFramework.

## 2.12.1.1
* Update ad display failed error code.

## 2.12.1.0
* Certified with Verve SDK 2.12.1.

## 2.11.1.4
* Add check for SDK initialization before loading an ad.

## 2.11.1.3
* Add support for passing in a presenting view controller.

## 2.11.1.2
* Add support for passing local parameter "is_location_collection_enabled" to set `+[HyBid setLocationUpdates:]`.

## 2.11.1.1
* Add support for location updates.

## 2.11.1.0
* Certified with Verve SDK 2.11.1.

## 2.11.0.1
* Update user consent to not override existing GDPR and CCPA privacy strings.

## 2.11.0.0
* Certified with Verve SDK 2.11.0.

## 2.10.0.0
* Certified with Verve SDK 2.10.0.
* Update open source versions to allow compilation with AppLovin SDK v11.0.0+.

## 2.9.1.0
* Certified with Verve SDK 2.9.1.

## 2.5.2.0
* Initial commit.
