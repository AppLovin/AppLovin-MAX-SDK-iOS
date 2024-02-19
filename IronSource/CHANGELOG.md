# Changelog

## 7.8.0.0.0
* Certified with IronSource SDK 7.8.0.0.

## 7.7.0.0.1
* Correctly map `No available ad to load` errors to MAX NO FILLs instead of unspecified errors.

## 7.7.0.0.0
* Certified with IronSource SDK 7.7.0.0.

## 7.6.0.0.0
* Certified with IronSource SDK 7.6.0.0.

## 7.5.1.0.0
* Certified with IronSource SDK 7.5.1.0.

## 7.5.0.0.0
* Certified with IronSource SDK 7.5.0.0.

## 7.4.0.0.1
* Add support for bidding on banners/MRECs, interstitials, and rewarded ads.

## 7.4.0.0.0
* Certified with IronSource SDK 7.4.0.0.
* Updated the minimum required iOS version to 11.0 to match IronSource SDK.
* Updated minimum Xcode requirement to 14.1.

## 7.3.1.0.1
* Fixed potential memory leaks by clearing delegates in `destroy:` method.   

## 7.3.1.0.0
* Certified with IronSource SDK 7.3.1.0.
* Remove the `privacySettingForSelector:fromParameters:` function and call privacy methods directly.
* Now requires MAX SDK version 6.14.0 or higher. 

## 7.3.0.0.0
* Certified with IronSource SDK 7.3.0.0.

## 7.2.7.0.1
* Update to use `setISDemandOnlyBannerDelegate:forInstanceId:` API to support setting a new delegate for each banner/MREC instance.

## 7.2.7.0.0
* Certified with IronSource SDK 7.2.7.0.

## 7.2.6.0.2
* Remove `consentDialogState` guard.

## 7.2.6.0.1
* Update to use `+[MAAdapterError errorWithCode:errorString:thirdPartySdkErrorCode:thirdPartySdkErrorMessage:]` to avoid crashes with AppLovin SDK 11.4.1 and earlier.

## 7.2.6.0.0
* Certified with IronSource SDK 7.2.6.0.

## 7.2.5.1.2
* Update error code mapping for SDK error reports.

## 7.2.5.1.1
* Add support for banners and MRECs.
* Disable bitcode, as Apple deprecated it in Xcode 14 (https://developer.apple.com/documentation/xcode-release-notes/xcode-14-release-notes).
* Add additional details for ad display failures. 

## 7.2.5.1.0
* Certified with IronSource SDK 7.2.5.1.

## 7.2.5.0.0
* Certified with IronSource SDK 7.2.5.0.

## 7.2.4.0.0
* Certified with IronSource SDK 7.2.4.0.

## 7.2.3.1.0
* Certified with IronSource SDK 7.2.3.1.

## 7.2.3.0.0
* Certified with IronSource SDK 7.2.3.0.

## 7.2.2.1.0
* Certified with IronSource SDK 7.2.2.1.

## 7.2.2.0.0
* Certified with IronSource SDK 7.2.2.0.
* Distribute adapter as an XCFramework.
* Silence API deprecation warnings.

## 7.2.1.2.1
* Update ad display failed error code.

## 7.2.1.2.0
* Certified with IronSource SDK 7.2.1.2.

## 7.2.1.0.2
* Downgrade IronSource SDK to 7.2.0.0, because newer SDK versions break AppLovin SDK's initialization logic.

## 7.2.1.0.1
* Add support for passing in a presenting view controller.

## 7.2.1.0.0
* Certified with IronSource SDK 7.2.1.0.

## 7.2.0.0.0
* Certified with IronSource SDK 7.2.0.

## 7.1.14.0.0
* Certified with IronSource SDK 7.1.14.0.
* Update open source versions to allow compilation with AppLovin SDK v11.0.0+.

## 7.1.13.0.0
* Certified with IronSource SDK 7.1.13.0.

## 7.1.12.0.0
* Certified with IronSource SDK 7.1.12.0.

## 7.1.11.1.0
* Certified with IronSource SDK 7.1.11.1.

## 7.1.11.0.0
* Certified with IronSource SDK 7.1.11.0.

## 7.1.10.0.0
* Certified with IronSource SDK 7.1.10.0.

## 7.1.6.1.0
* Certified with IronSource SDK 7.1.6.1.
* Update podspec to use `pod_target_xcconfig` over the deprecated `xcconfig`.

## 7.1.5.0.0
* Certified with IronSource SDK 7.1.5.0.

## 7.1.4.0.0
* Certified with IronSource SDK 7.1.4.0.

## 7.1.3.0.0
* Certified with IronSource SDK 7.1.3.0.

## 7.1.2.0.0
* Certified with IronSource SDK 7.1.2.0.
* Support flexible selective ad format initialization for IronSource SDK.

## 7.1.1.0.1
* Added COPPA support.

## 7.1.1.0.0
* Certified with IronSource SDK 7.1.1.0.
* Update podspec source from bintray to S3.

## 7.1.0.0.0
* Certified with IronSource SDK 7.1.0.0.
* Add support to pass 3rd-party error code and description to SDK.

## 7.0.4.0.0
* Certified with IronSource SDK 7.0.4.0.

## 7.0.3.0.2
* Only call `setMetaDataWithKey:Value:` before initializing ironSource SDK.

## 7.0.3.0.1
* Only set user consent flag if GDPR applies.

## 7.0.3.0.0
* Certified with IronSource SDK 7.0.3.0.

## 7.0.2.0.0
* Certified with IronSource SDK 7.0.2.0.

## 7.0.1.0.1
* Update 7000000 version check to 6140000.
* Update initialization log.

## 7.0.1.0.0
* Certified with IronSource SDK 7.0.1.0.
* Removed the i386 slice. Adapter will no longer work on 32-bit simulators.

## 7.0.0.0.1
* Update 70000 version check to 7000000.

## 7.0.0.0.0
* Certified with IronSource SDK 7.0.0.0. (iOS14)
