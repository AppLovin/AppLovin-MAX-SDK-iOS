# Changelog

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
