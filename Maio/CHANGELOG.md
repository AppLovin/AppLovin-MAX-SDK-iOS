# Changelog

## 2.1.5.0
* Certified with Maio SDK 2.1.5.

## 2.1.4.1
* Updated minimum Xcode requirement to 15.0.
* Remove deprecated callbacks `didStartRewardedAdVideo` and `didCompleteRewardedAdVideo`.

## 2.1.4.0
* Certified with Maio SDK 2.1.4.

## 2.1.3.0
* Certified with Maio SDK 2.1.3.

## 2.1.2.0
* Certified with Maio SDK 2.1.2.

## 2.1.1.0
* Certified with Maio SDK 2.1.1.
* Update to use instance based APIs.
* Update the minimum required iOS version to 12.0 in Pod Spec to match Maio SDK.

## 1.6.3.3
* Fixed `maioDidCloseAd:` callback not fired caused by clearing delegates in `destroy:` method. 
* Updated minimum Xcode requirement to 14.1.

## 1.6.3.2
* Updated minimum Xcode requirement to 14.0.
* Fixed potential memory leaks by clearing delegates in `destroy:` method.   

## 1.6.3.1
* Disable bitcode, as Apple deprecated it in Xcode 14 (https://developer.apple.com/documentation/xcode-release-notes/xcode-14-release-notes).
* Update to use `[MAAdapterError errorWithCode:errorString:thirdPartySdkErrorCode:thirdPartySdkErrorMessage:]` to avoid crashes with AppLovin SDK 11.4.1 and earlier.

## 1.6.3.0
* Certified with Maio SDK 1.6.3.
* Silence API deprecation warnings.
* Add additional details for ad display failures. 

## 1.6.2.0
* Certified with Maio SDK 1.6.2.
* Distribute adapter as an XCFramework.

## 1.6.1.1
* Update ad display failed error code.

## 1.6.1.0
* Certified with Maio SDK 1.6.1.

## 1.5.8.1
* Remove `ALMaioZoneIds` since it is unused.
* Update open source versions to allow compilation with AppLovin SDK v11.0.0+.
* Add support for passing in a presenting view controller.

## 1.5.8.0
* Certified with Maio SDK 1.5.8.

## 1.5.7.1
* Downgrade to Maio SDK 1.5.6

## 1.5.7.0
* Certified with Maio SDK 1.5.7.
* Update podspec to use `pod_target_xcconfig` over the deprecated `xcconfig`.

## 1.5.6.1
* Add support to pass 3rd-party error code and description to SDK.
* Update podspec source from bintray to S3.

## 1.5.6.0
* Certified with Maio SDK 1.5.6.

## 1.5.5.0
* Certified with Maio SDK 1.5.5.
* Removed the i386 slice. Adapter will no longer work on 32-bit simulators.

## 1.5.4.0
* Certified with Maio SDK 1.5.4.
* Fix ad display failed callback not firing in rare cases.

## 1.5.3.0
* Certified with SDK 1.5.3.

## 1.5.2.0
* Certified with SDK 1.5.2.

## 1.5.0.2
* If an ad is not ready when requested, consider it a no fill instead of waiting.

## 1.5.0.1
* Add configuration of rewards from server parameters.
* Fix incorrect `Unspecified` and `No Fill` errors due to keeping ad load state between ads.

## 1.5.0.0
* Certified with SDK 1.5.0.

## 1.4.8.0
* Certified with SDK 1.4.8.

## 1.4.7.0
* Initial commit.
