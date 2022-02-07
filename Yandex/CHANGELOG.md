# Changelog

## 4.4.2.1
* Update open source versions to allow compilation with AppLovin SDK v11.0.0+.
* Add impression callback for ad view ads.

## 4.4.2.0
* Certified with Yandex SDK 4.4.2.

## 4.4.1.0
* Certified with Yandex SDK 4.4.1.

## 4.3.0.0
* Certified with Yandex SDK 4.3.0.
* Update and remove deprecated API usages.

## 2.20.0.1
* Update podspec source from bintray to S3.
* Update podspec to use `pod_target_xcconfig` over the deprecated `xcconfig`.

## 2.20.0.0
* Certified with Yandex SDK 2.20.0.
* Add support to pass 3rd-party error code and description to SDK.

## 2.19.0.1
* Only set user consent flag if GDPR applies.

## 2.19.0.0
* Certified with Yandex SDK 2.19.0.

## 2.18.0.1
* Removed the i386 slice. Adapter will no longer work on 32-bit simulators.
* Update 7000000 version check to 6140000.

## 2.18.0.0
* Certified with Yandex SDK 2.18.0.

## 2.17.0.2
* Update 70000 version check to 7000000.

## 2.17.0.1
* Add display callbacks for test mode interstitial and rewarded ads.

## 2.17.0.0
* Certified with Yandex SDK 2.17.0.

## 2.15.4.4
* Fix incorrect adapter version returned by the adapter.

## 2.15.4.3
* Updated to not set privacy settings if nil.

## 2.15.4.2
* Roll back privacy settings.

## 2.15.4.1
* Updated to not set privacy settings if nil.

## 2.15.4.0
* Certified with Yandex SDK 2.15.4.
* Add custom parameters in ad requests as requested by Yandex.
* Add new `didTrackAdapterImpression:` for tracking interstitial and rewarded ad impressions.
* Remove tracking impressions in original fullscreen `didAppear:` methods. 

## 2.14.0.1
* Fix adapter versioning.

## 2.14.0.0
* Certified with Yandex SDK 2.14.0.
* Add configuration of rewards from server parameters.

## 2.13.3.0
* Certified with Yandex SDK 2.13.3.

## 2.13.2.0
* Initial commit.
