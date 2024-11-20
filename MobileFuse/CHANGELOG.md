# Changelog

## 1.8.1.0
* Certified with MobileFuse SDK 1.8.1.
* Removed redundant log output when initialization was already completed.

## 1.8.0.1
* Remove passing in of consent string as it has been deprecated.

## 1.8.0.0
* Certified with MobileFuse SDK 1.8.0.

## 1.7.6.1
* Requires minimum AppLovin MAX SDK version be 13.0.0.
* Removed COPPA support.
* Remove deprecated native API usages.

## 1.7.6.0
* Certified with MobileFuse SDK 1.7.6.

## 1.7.5.0
* Certified with MobileFuse SDK 1.7.5.
* Updated minimum Xcode requirement to 15.0.

## 1.7.4.0
* Certified with MobileFuse SDK 1.7.4.
* Replace deprecated API `MFAd.isAdReady` with new API `MFAd.isLoaded`.

## 1.7.3.0
* Certified with MobileFuse SDK 1.7.3.

## 1.7.2.0
* Certified with MobileFuse SDK 1.7.2.

## 1.7.1.0
* Certified with MobileFuse SDK 1.7.1.

## 1.7.0.0
* Certified with MobileFuse SDK 1.7.0.
* Updated minimum iOS version to 11.0.

## 1.6.5.0
* Certified with MobileFuse SDK 1.6.5.

## 1.6.4.0
* Certified with MobileFuse SDK 1.6.4.

## 1.6.3.0
* Certified with MobileFuse SDK 1.6.3.

## 1.6.2.0
* Certified with MobileFuse SDK 1.6.2.

## 1.6.1.0
* Certified with MobileFuse SDK 1.6.1.

## 1.6.0.0
* Certified with MobileFuse SDK 1.6.0.
* Initialize MobileFuse SDK using new API with initialization callbacks.
* Updated deprecated method `getTokenWithRequest:` to new `getTokenWithRequest:withCallback:`.
* Collect MobileFuse SDK version on the main thread to fix runtime warning.
* Updated minimum Xcode requirement to 14.1.
* Fixed potential memory leaks by clearing delegates in `destroy:` method.   

## 1.5.2.0
* Certified with MobileFuse SDK 1.5.2.

## 1.5.1.0
* Certified with MobileFuse SDK 1.5.1.

## 1.5.0.0
* Certified with MobileFuse SDK 1.5.0.

## 1.4.5.0
* Certified with MobileFuse SDK 1.4.5.

## 1.4.4.0
* Certified with MobileFuse SDK 1.4.4.

## 1.4.0.2
* Enable native ads for Mediation Debugger.

## 1.4.0.1
* Add support for interstitial, rewarded, native and native ad view ads.

## 1.4.0.0
* Certified with MobileFuse SDK 1.4.0.
* Disable bitcode, as Apple deprecated it in Xcode 14 (https://developer.apple.com/documentation/xcode-release-notes/xcode-14-release-notes).

## 1.3.1.0
* Certified with MobileFuse SDK 1.3.1. 

## 1.3.0.0
* Initial commit.
* Minimum AppLovin MAX SDK version 11.5.2.
