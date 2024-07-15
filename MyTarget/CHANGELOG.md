# Changelog

## 5.21.5.0
* Certified with MyTarget SDK 5.21.5.

## 5.21.4.0
* Certified with MyTarget SDK 5.21.4.

## 5.21.3.0
* Certified with MyTarget SDK 5.21.3.
* Updated minimum Xcode requirement to 15.0.

## 5.21.2.0
* Certified with MyTarget SDK 5.21.2.
* Remove deprecated callbacks `didStartRewardedAdVideo` and `didCompleteRewardedAdVideo`.

## 5.21.1.0
* Certified with MyTarget SDK 5.21.1.

## 5.21.0.0
* Certified with MyTarget SDK 5.21.0.
* Added `onMediaLoadFailed` method to `MyTargetNativeAdAdapterDelegate`.

## 5.20.1.1
* Fully re-written in Swift.
* Updated minimum AppLovinSDK requirement to 12.0.0.

## 5.20.1.0
* Certified with MyTarget SDK 5.20.1.

## 5.20.0.0
* Certified with MyTarget SDK 5.20.0.

## 5.19.0.0
* Certified with MyTarget SDK 5.19.0.
* Updated the minimum required iOS version to 12.4 to match MyTarget SDK. 

## 5.18.0.1
* Updated minimum Xcode requirement to 14.1.
* Remove deprecated and unnecessary APIs.
* Implement `onLoadFailedWithError:` methods to fix `NSInvalidArgumentException` crashes on ad load failure.

## 5.18.0.0
* Certified with MyTarget SDK 5.18.0.
* Fixed potential memory leaks by clearing delegates in `destroy:` method.   

## 5.17.5.0
* Certified with MyTarget SDK 5.17.5.
* Remove the `privacySettingForSelector:fromParameters:` function and call privacy methods directly.
* Now requires MAX SDK version 6.14.0 or higher. 

## 5.17.4.1
* Updated `ALMyTargetMediationAdapterNativeDelegate` to conform to `MTRGNativeAdMediaDelegate`.

## 5.17.4.0
* Certified with MyTarget SDK 5.17.4.
* Updated minimum Xcode requirement to 14.0.
* Updated the minimum required iOS version to 10.0 in Pod Spec to match myTargetSDK. 
* Removed support for armv7 devices.

## 5.16.0.2
* Remove `consentDialogState` guard.

## 5.16.0.1
* Support for native ads in external plugins (e.g. React Native).
* Disable bitcode, as Apple deprecated it in Xcode 14 (https://developer.apple.com/documentation/xcode-release-notes/xcode-14-release-notes).

## 5.16.0.0
* Certified with MyTarget SDK 5.16.0.

## 5.15.2.2
* Update privacy settings before collecting signal. 

## 5.15.2.1
* Add support for returning the main image asset in `MANativeAd` for native ads.

## 5.15.2.0
* Certified with MyTarget SDK 5.15.2.

## 5.15.1.2
* Add support for providing native media content aspect ratio in `MANativeAdView`.
* Distribute adapter as an XCFramework.

## 5.15.1.1
* Remove check for manual native ad assets.

## 5.15.1.0
* Certified with MyTarget SDK 5.15.1.

## 5.15.0.2
* Add support for passing in a presenting view controller.

## 5.15.0.1
* Add support for Binary CCPA.  

## 5.15.0.0
* Certified with MyTarget SDK 5.15.0.

## 5.14.4.3
* Update open source versions to allow compilation with AppLovin SDK v11.0.0+.
* Add SDK initialization code : `initSdk()`.

## 5.14.4.2
* Properly destroy native ad.

## 5.14.4.1
* Fix icon view never getting registered for interaction.

## 5.14.4.0
* Certified with MyTarget SDK 5.14.4.

## 5.14.2.0
* Certified with MyTarget SDK 5.14.2.
* Added support for native bidding.

## 5.12.0.1
* Downgrade to MyTarget SDK 5.11.1.

## 5.12.0.0
* Certified with MyTarget SDK 5.12.0.

## 5.11.1.0
* Certified with MyTarget SDK 5.11.1.

## 5.11.0.0
* Certified with MyTarget SDK 5.11.0.
* Update podspec to use `pod_target_xcconfig` over the deprecated `xcconfig`.

## 5.10.3.0
* Certified with MyTarget SDK 5.10.3.

## 5.10.2.0
* Certified with MyTarget SDK 5.10.2.

## 5.10.1.0
* Certified with MyTarget SDK 5.10.1.

## 5.10.0.0
* Certified with MyTarget SDK 5.10.0.
* Update podspec source from bintray to S3.

## 5.9.11.0
* Certified with MyTarget SDK 5.9.11.

## 5.9.10.0
* Certified with MyTarget SDK 5.9.10.
* Add support to pass 3rd-party error code and description to SDK.

## 5.9.9.0
* Certified with MyTarget SDK 5.9.9.

## 5.9.8.0
* Certified with MyTarget SDK 5.9.8.

## 5.9.7.0
* Certified with MyTarget SDK 5.9.7.

## 5.9.6.0
* Certified with MyTarget SDK 5.9.6.

## 5.9.5.0
* Certified with MyTarget SDK 5.9.5.

## 5.9.4.1
* Only set user consent flag if GDPR applies.

## 5.9.4.0
* Certified with MyTarget SDK 5.9.4.

## 5.9.3.0
* Certified with myTarget SDK 5.9.3.
* Added support for header bidding.
* Updated to new `MTRGAdView`, `MTRGAdSize`, and `MTRGRewardedAd` APIs.
* Added `setDebugMode` based on `isTesting` in initialize method.
* Stop forwarding expand and collapse callbacks for ad views.

## 5.7.5.1
* Removed the i386 slice. Adapter will no longer work on 32-bit simulators.
* Update 7000000 version check to 6140000.

## 5.7.5.0
* Certified with MyTarget SDK 5.7.5.

## 5.7.4.1
* Update 70000 version check to 7000000.

## 5.7.4.0
* Certified with MyTarget SDK 5.7.4.

## 5.7.3.0
* Certified with MyTarget SDK 5.7.3.

## 5.6.3.5
* Fix incorrect adapter version returned by the adapter.

## 5.6.3.4
* Updated to not set privacy settings if nil.

## 5.6.3.3
* Roll back privacy changes.

## 5.6.3.2
* Updated to not set privacy settings if nil.

## 5.6.3.1
* Fix versioning.

## 5.6.3.0
* Certified with MyTarget SDK 5.6.3.

## 5.6.2.0
* Certified with MyTarget SDK 5.6.2.

## 5.6.1.0
* Certified with MyTarget SDK 5.6.1.

## 5.6.0.0
* Certified with MyTarget SDK 5.6.0.

## 5.5.1.0
* Certified with myTarget SDK 5.5.1.

## 5.4.8.0
* Certified with myTarget SDK 5.4.8.

## 5.4.5.0
* Certified with myTarget SDK 5.4.5.

## 5.4.0.0
* Certified with myTarget SDK 5.4.0.

## 5.3.5.0
* Certified with myTarget SDK 5.3.5.
* Remove unused server parameters.

## 5.3.3.0
* Initial commit.
