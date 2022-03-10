# Changelog

## 4.8.0.0.0
* Certified with AdColony SDK 4.8.0.

## 4.7.2.0.1
* Update open source versions to allow compilation with AppLovin SDK v11.0.0+.
* Add support for passing in a presenting view controller.

## 4.7.2.0.0
* Certified with AdColony SDK 4.7.2.

## 4.6.1.0.2
* Add support for sequential rewarded ads (to ensure the "did reward user" callback is called).

## 4.6.1.0.1
* Downgrade to AdColony SDK 4.6.0.

## 4.6.1.0.0
* Certified with AdColony SDK 4.6.1.
* Update podspec to use `pod_target_xcconfig` over the deprecated `xcconfig`.

## 4.6.0.0.0
* Certified with AdColony SDK 4.6.0.

## 4.5.0.0.3
* Update deprecated method `collectSignals` to new `collectSignals:`.

## 4.5.0.0.2
* Update podspec source from bintray to S3.
* Remove setting COPPA string to empty.

## 4.5.0.0.1
* Fix COPPA & CCPA "required" even if set to false by publisher.

## 4.5.0.0.0
* Certified with AdColony SDK 4.5.0.
* Add support to pass 3rd-party error code and description to SDK.

## 4.4.1.1.1
* Only set user consent flag if GDPR applies.
* When consent dialog state is .APPLIES, set privacy framework required for .GDPR to be true, else if state is .DOES_NOT_APPLY, set privacy framework required for .GDPR to be false.

## 4.4.1.1.0
* Certified with AdColony SDK 4.4.1.1.

## 4.4.1.0
* Certified with AdColony SDK 4.4.1.

## 4.4.0.1
* Fix setting of `hasUserConsent` if value is `nil`. 

## 4.4.0.0
* Certified with AdColony SDK 4.4.0.

## 4.3.1.1
* Update 7000000 version check to 6140000.
* Update initialization log.

## 4.3.1.0
* Certified with AdColony SDK 4.3.1.

## 4.3.0.3
* Removed the i386 slice. Adapter will no longer work on 32-bit simulators.

## 4.3.0.2
* Update 70000 version check to 7000000.

## 4.3.0.1
* Update 61400 version check to 70000.

## 4.3.0.0
* Certified with AdColony SDK 4.3.0.

## 4.2.0.0
* Certified with AdColony SDK 4.2.0.
* Updated deprecated GDPR API usages.
* Added CCPA support.
* Added COPPA support.
* Added bidding support.
* Added banner/MREC support.

## 4.1.5.4
* Fix incorrect adapter version returned by the adapter.

## 4.1.5.3
* Updated to not set privacy settings if nil.

## 4.1.5.2
* Roll back privacy setting changes.

## 4.1.5.1
* Updated to not set privacy settings if nil.

## 4.1.5.0
* Certified with AdColony SDK 4.1.5.

## 4.1.4.0
* Certified with AdColony SDK 4.1.4.

## 4.1.3.0
* Certified with AdColony SDK 4.1.3.

## 4.1.2.0
* Certified with AdColony SDK 4.1.2.
* Updated deprecated API usages.
* Updated the minimum required AppLovin SDK version to 6.5.0.

## 4.1.0.0
* Certified with AdColony SDK 4.1.0.

## 3.3.8.2
* Fix crash related to AdColony ad expiration.

## 3.3.8.1
* Add support for initialization status.
* Do not reload expired AdColony ads from adapter (MAX SDK will handle it).

## 3.3.8.0
* Certified with AdColony SDK 3.3.8.

## 3.3.7.2
* Add Unity support for automatic dependency resolution. Please ensure that you are on the latest [AppLovin MAX Unity Plugin](https://bintray.com/applovin/Unity/applovin-max-unity-plugin).
* Add support for extra reward options.

## 3.3.7.1
* Add error code for when SDK is not initialized.
* Update adapter logging.

## 3.3.7.0
* Initial commit.
