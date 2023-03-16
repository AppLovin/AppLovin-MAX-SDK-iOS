# Changelog

## 2.0.0.6.0
* Certified with BidMachine SDK 2.0.0.6.

## 2.0.0.5.0
* Certified with BidMachine SDK 2.0.0.5.
* Update to use new APIs.
* Remove `consentDialogState` guard.

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
