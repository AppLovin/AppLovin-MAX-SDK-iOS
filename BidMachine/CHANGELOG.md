# Changelog

## 3.0.0.0.1
* Add AppLovin MAX SDK version 13.0.0+ as a CocoaPods dependency.
* Removed COPPA support.
* Remove deprecated native API usages.

## 3.0.0.0.0
* Certified with BidMachine SDK 3.0.0.

## 2.7.0.0.0
* Certified with BidMachine SDK 2.7.0.
* Updated minimum Xcode requirement to 15.0.

## 2.6.1.0.0
* Certified with BidMachine SDK 2.6.1.

## 2.6.0.0.0
* Certified with BidMachine SDK 2.6.0.

## 2.5.3.0.0
* Certified with BidMachine SDK 2.5.3.

## 2.5.2.0.0
* Certified with BidMachine SDK 2.5.2.

## 2.5.1.0.0
* Certified with BidMachine SDK 2.5.1.

## 2.5.0.0.0
* Certified with BidMachine SDK 2.5.0.

## 2.4.0.3.0
* Certified with BidMachine SDK 2.4.0.3.

## 2.4.0.2.0
* Certified with BidMachine SDK 2.4.0.2.

## 2.4.0.1.0
* Certified with BidMachine SDK 2.4.0.1.

## 2.4.0.0.0
* Certified with BidMachine SDK 2.4.0.0.

## 2.3.0.2.0
* Certified with BidMachine SDK 2.3.0.2.

## 2.3.0.0.0
* Certified with BidMachine SDK 2.3.0.0.
* Updated minimum Xcode requirement to 14.1.
* Fixed potential memory leaks by clearing delegates in `destroy:` method.   

## 2.1.0.0.1
* Updated `[BidMachine tokenWith:completion:]` usage.

## 2.1.0.0.0
* Certified with BidMachine SDK 2.1.0.0.

## 2.0.1.0.0
* Certified with BidMachine SDK 2.0.1.0.
* Updated the minimum required iOS version to 12.0 in Pod Spec to match BidMachine SDK.

## 2.0.0.6.1
* Add support for IAB's TCFv2 GDPR consent string. Note that you must be on the AppLovin MAX SDK v11.4.2+ and use a TCFv2-compliant framework which stores the consent string in User Defaults via the `IABTCF_TCString` key to use this feature. BidMachine's iOS SDK requires that the adapter passes the TCFv2 GDPR consent string, the BidMachine Android SDK does not.

## 2.0.0.6.0
* Certified with BidMachine SDK 2.0.0.6.

## 2.0.0.5.0
* Certified with BidMachine SDK 2.0.0.5.
* Update to use new APIs.
* Remove `consentDialogState` guard.
* Updated minimum Xcode requirement to 14.0.

## 1.9.5.1.0
* Certified with BidMachine SDK 1.9.5.1.

## 1.9.5.0.3
* Update to use `+[MAAdapterError errorWithCode:errorString:thirdPartySdkErrorCode:thirdPartySdkErrorMessage:]` to avoid crashes with AppLovin SDK 11.4.1 and earlier.

## 1.9.5.0.2
* Support for native ads in external plugins (e.g. React Native).

## 1.9.5.0.1
* Update error code mapping for SDK error reports.
* Disable bitcode, as Apple deprecated it in Xcode 14 (https://developer.apple.com/documentation/xcode-release-notes/xcode-14-release-notes).
* Add additional details for ad display failures. 

## 1.9.5.0.0
* Certified with BidMachine SDK 1.9.5.0.
* Add CCPA support.

## 1.9.4.8.0
* Certified with BidMachine SDK 1.9.4.8.

## 1.9.4.1.2
* Add support for passing creative id to SDK.

## 1.9.4.1.1
* Add support for returning the main image asset in `MANativeAd` for native ads.

## 1.9.4.1.0
* Certified with BidMachine SDK 1.9.4.1.
* Silence API deprecation warnings.

## 1.9.2.0.2
* Distribute adapter as an XCFramework.
* Use server parameters instead of custom parameters.

## 1.9.2.0.1
* Update ad display failed error code.

## 1.9.2.0.0    
* Initial commit.
* Minimum AppLovin MAX SDK version 11.4.0.
