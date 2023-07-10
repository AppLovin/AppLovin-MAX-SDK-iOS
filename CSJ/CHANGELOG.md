# Changelog

## 4.9.0.7.2
* Updated minimum Xcode requirement to 14.0.
* Fixed potential memory leaks by clearing delegates in `destroy:` method.   
* Fix native banner/MREC impression and clicks not firing.

## 4.9.0.7.1
* Removed unused `kDefaultAppOpenAdLoadingTimeoutSeconds` constant.
* Added switch statement to handle `BUErrorCodeBiddingAdmExpired` error case.

## 4.9.0.7.0
* Certified with ByteDance China SDK 4.9.0.7.

## 4.7.1.1.2
* Support for native ads in external plugins (e.g. React Native).
* Disable bitcode, as Apple deprecated it in Xcode 14 (https://developer.apple.com/documentation/xcode-release-notes/xcode-14-release-notes).

## 4.7.1.1.1
* Updated the dependency to `Ads-CN/BUAdSDK_Compatible`.

## 4.7.1.1.0
* Initial commit.
* Minimum AppLovin MAX SDK version 11.5.2.
