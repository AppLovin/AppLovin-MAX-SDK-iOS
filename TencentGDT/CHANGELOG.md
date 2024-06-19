# Changelog

## 4.14.81.0
* Certified with TencentGDT SDK 4.14.81.

## 4.14.80.0
* Certified with TencentGDT SDK 4.14.80.

## 4.14.76.0
* Certified with TencentGDT SDK 4.14.76.
* Updated minimum Xcode requirement to 15.0.
* Updated deprecated APIs.

## 4.14.71.0
* Certified with TencentGDT SDK 4.14.71.
* Remove deprecated callbacks `didStartRewardedAdVideo` and `didCompleteRewardedAdVideo`.

## 4.14.70.0
* Certified with TencentGDT SDK 4.14.70.

## 4.14.63.0
* Certified with TencentGDT SDK 4.14.63.

## 4.14.62.0
* Certified with TencentGDT SDK 4.14.62.

## 4.14.60.0
* Certified with TencentGDT SDK 4.14.60.

## 4.14.50.0
* Certified with TencentGDT SDK 4.14.50.
* Updated minimum iOS version to 11.0.

## 4.14.45.0
* Certified with TencentGDT SDK 4.14.45.

## 4.14.42.0
* Certified with TencentGDT SDK 4.14.42.

## 4.14.40.0
* Certified with TencentGDT SDK 4.14.40.
* Updated minimum Xcode requirement to 14.1.

## 4.14.32.0
* Certified with TencentGDT SDK 4.14.32.
* Updated minimum Xcode requirement to 14.0.
* Remove arm64 simulator slice to match TencentGDT SDK.

## 4.14.31.0
* Certified with TencentGDT SDK 4.14.31.
* Fixed potential memory leaks by clearing delegates in `destroy:` method.   

## 4.14.30.0
* Certified with TencentGDT SDK 4.14.30.

## 4.14.22.0
* Certified with TencentGDT SDK 4.14.22.

## 4.14.20.0
* Certified with TencentGDT SDK 4.14.20.

## 4.14.12.0
* Certified with TencentGDT SDK 4.14.12.

## 4.14.11.0
* Certified with TencentGDT SDK 4.14.11.

## 4.14.10.0
* Certified with TencentGDT SDK 4.14.10.

## 4.14.02.1
* Update to use `[MAAdapterError errorWithCode:errorString:thirdPartySdkErrorCode:thirdPartySdkErrorMessage:]` to avoid crashes with AppLovin SDK 11.4.1 and earlier.

## 4.14.02.0
* Certified with TencentGDT SDK 4.14.02.

## 4.14.01.0
* Certified with TencentGDT SDK 4.14.01.

## 4.13.90.1
* Update Error Code Mapping for SDK Error Codes
* Disable bitcode, as Apple deprecated it in Xcode 14 (https://developer.apple.com/documentation/xcode-release-notes/xcode-14-release-notes).
* Add additional details for ad display failures. 

## 4.13.90.0
* Certified with TencentGDT SDK 4.13.90.

## 4.13.84.0
* Certified with TencentGDT SDK 4.13.84.
* Distribute adapter as an XCFramework.
* Silence API deprecation warnings.

## 4.12.4.4
* Update ad display failed error code.

## 4.12.4.3
* Update podspec to use `pod_target_xcconfig` over the deprecated `xcconfig`.
* Update open source versions to allow compilation with AppLovin SDK v11.0.0+.
* Add support for passing in a presenting view controller.

## 4.12.4.2
* Added support for `videoMuted` property for fullscreen ads.

## 4.12.4.1
* Downgraded to TencentGDT SDK 4.12.3 because 4.12.4 is obfuscated.

## 4.12.4.0
* Certified with TencentGDT SDK 4.12.4.

## 4.12.3.2
* Update podspec source from bintray to S3.
* Implemented `unifiedInterstitialFailToPresent:error:` and `unifiedInterstitialAd:playerStatusChanged:` callbacks.

## 4.12.3.1
* Update deprecated callback `gdt_rewardVideoAdDidRewardEffective:` to `gdt_rewardVideoAdDidRewardEffective:info:`.

## 4.12.3.0
* Certified with TencentGDT SDK 4.12.3.
* Add support to pass 3rd-party error code and description to SDK.

## 4.12.1.0
* Certified with TencentGDT SDK 4.12.1.

## 4.12.0.0
* Certified with TencentGDT SDK 4.12.0.

## 4.11.12.0
* Certified with Tencent GDTMobSDK 4.11.12.

## 4.11.10.0
* Certified with Tencent GDTMobSDK 4.11.10.
* Updated deprecated APIs.
* Removed the i386 slice. Adapter will no longer work on 32-bit simulators.

## 4.11.5.0
* Certified with Tencent GDTMobSDK 4.11.5.

## 4.11.3.0
* Certified with Tencent GDTMobSDK 4.11.3.

## 4.10.14.0
* Certified with Tencent GDTMobSDK 4.10.14.

## 4.10.13.1
* Enable support for Tencent rewarded video ads.

## 4.10.13.0
* Certified with Tencent GDTMobSDK 4.10.13.

## 4.10.11.0
* Certified with Tencent GDTMobSDK 4.10.11.

## 4.10.5.0
* Initial implementation.
