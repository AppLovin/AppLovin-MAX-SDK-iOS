# Changelog

## 4.8.0.0
* Certified with Criteo SDK 4.8.0.
* Return the correct SDK version.
* Updated the minimum required iOS version to 12.0 in Pod Spec to match CriteoPublisherSdk. 

## 4.5.0.7
* Update to use `[MAAdapterError errorWithCode:errorString:thirdPartySdkErrorCode:thirdPartySdkErrorMessage:]` to avoid crashes with AppLovin SDK 11.4.1 and earlier.

## 4.5.0.6
* Support for native ads in external plugins (e.g. React Native).
* Disable bitcode, as Apple deprecated it in Xcode 14 (https://developer.apple.com/documentation/xcode-release-notes/xcode-14-release-notes).
* Add additional details for ad display failures. 

## 4.5.0.5
* Distribute adapter as an XCFramework.
* Silence API deprecation warnings.
* Remove unnecessary privacy settings update during signal collection.
* Use local scope copy of native ad while preparing view.
* Add check to only invoke ad load APIs if SDK has been initialized.

## 4.5.0.4
* Update ad display failed error code.

## 4.5.0.3
* Remove check for manual native ad assets.

## 4.5.0.2
* Fix CCPA logic.

## 4.5.0.1
* Add support for passing in a presenting view controller.

## 4.5.0.0
* Initial Commit.
* Certified with Criteo SDK 4.5.0.
* Minimum AppLovin MAX SDK version 11.1.2.
