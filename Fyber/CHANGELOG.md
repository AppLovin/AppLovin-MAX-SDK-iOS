# Changelog

## 8.3.0.0
* Certified with Fyber SDK 8.3.0.
* Remove deprecated API usages.
* Updated minimum Xcode requirement to 15.0.
* Updated the minimum required iOS version to 12.0 to match Fyber SDK. 

## 8.2.8.0
* Certified with Fyber SDK 8.2.8.
* Remove deprecated callbacks `didStartRewardedAdVideo` and `didCompleteRewardedAdVideo`.

## 8.2.7.0
* Certified with Fyber SDK 8.2.7.

## 8.2.6.0
* Certified with Fyber SDK 8.2.6.

## 8.2.5.2
* Fix `-[__NSDictionaryM removeObjectForKey:] key cannot be nil` crash when spotID is `nil` in `adDidShowWithImpressionData:withAdRequest:` callback.

## 8.2.5.1
* Downgrade Fyber SDK to 8.2.4 due to `The signature cannot be verified` [issue](https://github.com/AppLovin/AppLovin-MAX-Unity-Plugin/issues/313) with `IASDKCore.xcframework`.

## 8.2.5.0
* Certified with Fyber SDK 8.2.5.

## 8.2.4.0
* Certified with Fyber SDK 8.2.4.
* Updated minimum Xcode requirement to 14.1.

## 8.2.3.0
* Certified with Fyber SDK 8.2.3.
* Updated minimum Xcode requirement to 14.0.
* Fixed potential memory leaks by clearing delegates in `destroy:` method. 

## 8.2.2.0
* Certified with Fyber SDK 8.2.2.

## 8.2.1.1
* Added COPPA support. 
* Remove the `privacySettingForSelector:fromParameters:` function and call privacy methods directly.
* Now requires MAX SDK version 6.14.0 or higher. 

## 8.2.1.0
* Certified with Fyber SDK 8.2.1.

## 8.2.0.1
* Fixed missing `didPayRevenueForAd:` callbacks and creative ids for some banners/MRECs.

## 8.2.0.0
* Certified with Fyber SDK 8.2.0.
* Updated the minimum required iOS version to 11.0 in Pod Spec to match Fyber Marketplace SDK. 

## 8.1.9.0
* Certified with Fyber SDK 8.1.9.

## 8.1.7.2
* Remove `consentDialogState` guard.

## 8.1.7.1
* Update to use `+[MAAdapterError errorWithCode:errorString:thirdPartySdkErrorCode:thirdPartySdkErrorMessage:]` to avoid crashes with AppLovin SDK 11.4.1 and earlier.

## 8.1.7.0
* Certified with Fyber SDK 8.1.7.
* Disable bitcode, as Apple deprecated it in Xcode 14 (https://developer.apple.com/documentation/xcode-release-notes/xcode-14-release-notes).
* Add additional details for ad display failures. 

## 8.1.6.0
* Certified with Fyber SDK 8.1.6.

## 8.1.5.2
* Update privacy settings before collecting signal. 

## 8.1.5.1
* Add support for IAB's TCFv2 GDPR consent string. Note that you must be on the AppLovin MAX SDK v11.4.2+ and use a TCFv2-compliant framework which stores the consent string in User Defaults via the `IABTCF_TCString` key to use this feature. Fyber will still be filtered out of the waterfall in GDPR regions if the string is not available or one of the criteria is not met.
* Silence API deprecation warnings.

## 8.1.5.0
* Certified with Fyber SDK 8.1.5.
* Distribute adapter as an XCFramework.

## 8.1.4.1
* Update ad display failed error code.
* Correctly map Fyber error code `497` to `-5202` ("Invalid Configuration") instead of `-5205` ("Third-Party Adapter Not Ready To Show Ad") in SDK error reports.

## 8.1.4.0
* Certified with Fyber SDK 8.1.4.

## 8.1.3.2
* Add support for passing in a presenting view controller.

## 8.1.3.1
* Add support for IAB's CCPA Privacy String.

## 8.1.3.0
* Certified with Fyber SDK 8.1.3.

## 8.1.2.0
* Certified with Fyber SDK 8.1.2.
* Update open source versions to allow compilation with AppLovin SDK v11.0.0+.

## 8.1.1.0
* Certified with Fyber SDK 8.1.1.

## 8.1.0.0
* Certified with Fyber SDK 8.1.0.

## 8.0.0.0
* Certified with Fyber SDK 8.0.0.
* Add support for bidding.

## 7.9.0.0
* Certified with Fyber SDK 7.9.0.

## 7.8.9.0
* Certified with Fyber SDK 7.8.9.
* Update to clear GDPR consent if it does not apply.
* Update podspec to use `pod_target_xcconfig` over the deprecated `xcconfig`.

## 7.8.3.2
* Downgrade Fyber SDK to 7.8.1 again.

## 7.8.3.1
* Downgrade Fyber SDK to 7.8.1.

## 7.8.3.0
* Certified with Fyber SDK 7.8.3.

## 7.8.2.4
* Set mediation type to `IAMediationMax`.

## 7.8.2.3
* Remove ad expiration callback implementations.

## 7.8.2.2
* Remove `isReady` checks.
* Downgrade Fyber SDK to 7.8.1 to avoid crashes in 7.8.2.

## 7.8.2.1
* Check `isReady` before attempting to display ad view.

## 7.8.2.0
* Certified with Fyber SDK 7.8.2.

## 7.8.1.3
* Implement adapter initialization using callback-based method.
* Update error codes mapping.

## 7.8.1.1
* Check `isReady` before attempting to display fullscreen ad.
* Implement `IAAdDidExpire:` and fail ad display there for fullscreen ads. 

## 7.8.1.0
* Certified with Fyber SDK 7.8.1.
* Update podspec source from bintray to S3.

## 7.8.0.2
* Fix `-[__NSDictionaryM removeObjectForKey:] key cannot be nil` silent crash when adapter is getting destroyed (to avoid spammy logs for pubs).

## 7.8.0.1
* Add support for passing creative id for banner ads to SDK (supported in iOS SDK 6.15.0+).

## 7.8.0.0
* Certified with Fyber SDK 7.8.0.

## 7.7.3.1
* Add support for passing creative id to SDK (supported in iOS SDK 6.15.0+).
* Add support to pass 3rd-party error code and description to SDK.

## 7.7.3.0
* Certified with Fyber SDK 7.7.3.

## 7.7.2.1
* Only set user consent flag if GDPR applies.

## 7.7.2.0
* Certified with Fyber SDK 7.7.2.

## 7.7.1.0
* Certified with Fyber SDK 7.7.1.

## 7.6.4.1
* Update 7000000 version check to 6140000.
* Update initialization log.

## 7.6.4.0
* Certified with Fyber SDK 7.6.4.
* Removed the i386 slice. Adapter will no longer work on 32-bit simulators.

## 7.6.3.3
* Pass user id to Fyber SDK.

## 7.6.3.2
* Update 70000 version check to 7000000.

## 7.6.3.1
* Re-enable logic in adapter `destroy` method.
* Update 61400 version check to 70000.

## 7.6.3.0
* Certified with Inneractive SDK 7.6.3.

## 7.6.2.0
* Include Fyber error string insted of just error code.
* Return invalid configuration error for `-1022` ATS error code.

## 7.6.1.0
* Certified with Inneractive SDK 7.6.1.

## 7.6.0.3
* Updated to not set privacy settings if nil.

## 7.6.0.2
* Roll back privacy changes.

## 7.6.0.1
* Updated to not set privacy settings if nil.

## 7.6.0.0
* Certified with Inneractive SDK 7.6.0.
* Use new `IAAdDidReward` callback to grant rewarded ad reward.

## 7.5.6.0
* Certified with Inneractive SDK 7.5.6.

## 7.5.5.1
* Actually certifiy with Inneractive SDK 7.5.5 

## 7.5.5.0
* Certified with Inneractive SDK 7.5.5 which fixes exported IPAs being unable to launch.

## 7.5.4.2
* Fix support for mute configuration.

## 7.5.4.1
* Add support for mute configuration.

## 7.5.4.0
* Certified with Inneractive SDK 7.5.4.
* Updated log to differentiate ad view formats.

## 7.5.3.0
* Certified with Inneractive SDK 7.5.3.
* Updated log to differentiate ad view formats.

## 7.5.1.0
* Certified with Inneractive SDK 7.5.1.

## 7.5.0.0
* Certified with Inneractive SDK 7.5.0.
* Removed support for muting/un-muting of ads.

## 7.4.1.0
* Updated the minimum required AppLovin SDK version to 6.5.0.

## 7.4.0.0
* Certified with Inneractive SDK 7.4.0.
* Use `Fyber_Marketplace_SDK` pod dependency. 

## 7.3.3.0
* Certified with Inneractive SDK 7.3.3.
* Prevent crashes by not logging NSError received when banners fail to load.

## 7.3.2.0
* Certified with Inneractive SDK 7.3.2.

## 7.3.0.2
* Fix potential logging crash.

## 7.3.0.1
* Add support for initialization status.

## 7.3.0.0
* Certified with Inneractive SDK 7.3.0.

## 7.2.1.2
* Add Unity support for automatic dependency resolution. Please ensure that you are on the latest [AppLovin MAX Unity Plugin](https://bintray.com/applovin/Unity/applovin-max-unity-plugin).
* Add support for extra reward options.

## 7.2.1.1
* Update adapter logging.

## 7.2.1.0
* Certified with Inneractive SDK 7.2.1.

## 7.1.1.0
* Initial commit.
