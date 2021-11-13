# Changelog

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
