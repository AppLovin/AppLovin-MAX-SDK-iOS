# Changelog

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
