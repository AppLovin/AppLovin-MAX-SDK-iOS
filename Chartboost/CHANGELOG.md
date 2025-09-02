# Changelog

## 9.9.3.0
* Certified with Chartboost SDK 9.9.3.

## 9.9.2.1
* Removed `isCached` checks to prevent valid ads from being blocked.

## 9.9.2.0
* Certified with Chartboost SDK 9.9.2.
* Distributed as a static framework within the XCFramework.

## 9.9.1.0
* Certified with Chartboost SDK 9.9.1.

## 9.9.0.1
* Implemented `didExpireAd:` in listeners to satisfy the updated Chartboost SDK callback interface.
* Update error code mapping.

## 9.9.0.0
* Certified with Chartboost SDK 9.9.0.
* Removed deprecated code paths based on the minimum supported AppLovin MAX SDK version 13.0.0.
* Updated minimum iOS version to 12.0.
* Updated ad display failed error code.

## 9.8.1.0
* Certified with Chartboost SDK 9.8.1.
* Removed redundant log output when initialization was already completed.

## 9.8.0.0
* Certified with Chartboost SDK 9.8.0.
* Simplified API calls by removing selector checks; direct API calls are now safe with the updated min SDK version.

## 9.7.0.2
* Requires minimum AppLovin MAX SDK version be 13.0.0.
* Removed COPPA support.

## 9.7.0.1
* Add bidding support for banners, leaders, MRECs, interstitial and rewarded ads.
* Add COPPA support.
* Updated minimum Xcode requirement to 15.0.
* Remove deprecated callbacks `didStartRewardedAdVideo` and `didCompleteRewardedAdVideo`.
* Update error code mapping.
* Remove deprecated API usages.

## 9.7.0.0
* Certified with Chartboost SDK 9.7.0.

## 9.6.0.0
* Certified with Chartboost SDK 9.6.0.

## 9.5.1.0
* Certified with Chartboost SDK 9.5.1.

## 9.5.0.0
* Certified with Chartboost SDK 9.5.0.

## 9.4.0.1
* Use `didRecordImpression:` instead of `didShowAd:` for impression tracking.

## 9.4.0.0
* Certified with Chartboost SDK 9.4.0.

## 9.3.1.0
* Certified with Chartboost SDK 9.3.1.
* Updated minimum Xcode requirement to 14.1.

## 9.3.0.1
* Fixed potential memory leaks by clearing delegates in `destroy:` method.   

## 9.3.0.0
* Certified with Chartboost SDK 9.3.0.
* Remove the `privacySettingForSelector:fromParameters:` function and call privacy methods directly.
* Now requires MAX SDK version 6.14.0 or higher. 

## 9.2.0.0
* Certified with Chartboost SDK 9.2.0.
* Updated the minimum required iOS version to 11.0 in Pod Spec to match ChartboostSDK. 
* Removed support for armv7 devices, as the ChartboostSDK does not support them.

## 9.1.0.1
* Disable bitcode, as Apple deprecated it in Xcode 14 (https://developer.apple.com/documentation/xcode-release-notes/xcode-14-release-notes).
* Add additional details for ad display failures. 
* Remove `consentDialogState` guard.

## 9.1.0.0
* Certified with Chartboost SDK 9.1.0.

## 9.0.0.0
* Certified with Chartboost SDK 9.0.0.
* Distribute adapter as an XCFramework.
* Silence API deprecation warnings.

## 8.5.0.4
* Update ad display failed error code.

## 8.5.0.3
* Update open source versions to allow compilation with AppLovin SDK v11.0.0+.
* Add support for passing in a presenting view controller.

## 8.5.0.2
* Certified with Chartboost SDK 8.5.0.1.

## 8.5.0.1
* Add support for banners and MRECs.

## 8.5.0.0
* Certified with Chartboost SDK 8.5.0.

## 8.4.2.0
* Certified with Chartboost SDK 8.4.2.

## 8.4.1.0
* Certified with Chartboost SDK 8.4.1.
* Update podspec source from bintray to S3.
* Update podspec to use `pod_target_xcconfig` over the deprecated `xcconfig`.

## 8.4.0.1
* Add support for passing creative id to SDK (supported in iOS SDK 6.15.0+).
* Add support to pass 3rd-party error code and description to SDK.

## 8.4.0.0
* Certified with Chartboost SDK 8.4.0.

## 8.3.1.1
* Only set user consent flag if GDPR applies.

## 8.3.1.0
* Certified with Chartboost SDK 8.3.1.

## 8.2.1.3
* Removed the i386 slice. Adapter will no longer work on 32-bit simulators.
* Update 7000000 version check to 6140000.
* Update initialization log.

## 8.2.1.2
* Update 70000 version check to 7000000.

## 8.2.1.1
* Update 61400 version check to 70000.

## 8.2.1.0
* Certified with Chartboost SDK 8.2.1.

## 8.2.0.5
* Fix incorrect adapter version returned by the adapter.

## 8.2.0.4
* Updated to not set privacy settings if nil.

## 8.2.0.3
* Roll back privacy changes.

## 8.2.0.2
* Add support for CCPA.
* Updated deprecated GDPR settings.
* Updated to not set privacy settings if nil.

## 8.2.0.1
* Fix versioning.

## 8.2.0.0
* Certified with Chartboost SDK 8.2.0.

## 8.1.0.1
* Update to use new initialization and delegate APIs.

## 8.1.0.0
* Certified with Chartboost SDK 8.1.0.
* Fix ad display failed callback not firing in rare cases.

## 8.0.4.0
* Certified with Chartboost SDK 8.0.4.

## 8.0.3.0
* Certified with Chartboost SDK 8.0.3.
* Updated the minimum required AppLovin SDK version to 6.5.0.
* Removed support for muting/un-muting of ads.

## 8.0.1.0
+ Certified with SDK 8.0.1.

## 7.5.0.2
* Add support for initialization status.

## 7.5.0.1
* Add Unity support for automatic dependency resolution. Please ensure that you are on the latest [AppLovin MAX Unity Plugin](https://bintray.com/applovin/Unity/applovin-max-unity-plugin).

## 7.5.0.0
* Certified with SDK 7.5.0.
* Add support for `[AD DISPLAY FAILED]` callbacks from Chartboost's `didFailToLoadInterstitial:withError:` and `didFailToLoadRewardedVideo:withError:` methods.
* Add support for extra reward options.

## 7.3.1.1
* Update adapter logging.

## 7.3.1.0
* Certified with Chartboost SDk 7.3.1.

## 7.3.0.0
* Initial commit.
