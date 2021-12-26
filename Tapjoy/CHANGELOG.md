# Changelog

## 12.8.1.0
* Certified with Tapjoy SDK 12.8.1.
* Update podspec to use `pod_target_xcconfig` over the deprecated `xcconfig`.

## 12.8.0.0
* Certified with Tapjoy SDK 12.8.0.

## 12.7.1.2
* Add support to pass 3rd-party error code and description to SDK.
* Update podspec source from bintray to S3.
* Use `-[TJPlacementVideoDelegate videoDidStart:]` for rewarded CIMPs.

## 12.7.1.1
* Remove support for setting user consent based on `"gdpr_applies"`.

## 12.7.1.0
* Certified with Tapjoy SDK 12.7.1.

## 12.7.0.0
* Certified with Tapjoy SDK 12.7.0.

## 12.6.1.6
* Removed the i386 slice. Adapter will no longer work on 32-bit simulators.
* Update 7000000 version check to 6140000.
* Update initialization log.

## 12.6.1.5
* Update 70000 version check to 7000000.

## 12.6.1.4
* Fix incorrect adapter version returned by the adapter.

## 12.6.1.3
* Updated to not set privacy settings if nil.

## 12.6.1.2
* Roll back privacy changes.

## 12.6.1.1
* Updated to not set privacy settings if nil.

## 12.6.1.0
* Certified with Tapjoy SDK 12.6.1.

## 12.6.0.3
* Update privacy APIs for GDPR.

## 12.6.0.2
* Certified with Tapjoy SDK 12.6.0.

## 12.6.0.1
* Standardize adapter version number.

## 12.6.0-beta.0
* Certified with Tapjoy SDK 12.6.0-beta.

## 12.4.2.0
* Certified with Tapjoy SDK 12.4.2.

## 12.4.1.0
* Certified with Tapjoy SDK 12.4.1.

## 12.4.0.0
* Certified with Tapjoy SDK 12.4.0.
* Use `videoDidStart: for CIMPs.
* Handle ad display failures for inters.

## 12.3.4.0
* Certified with Tapjoy SDK 12.3.4.
* Updated the minimum required AppLovin SDK version to 6.5.0.

## 12.3.3.0
* Certified with Tapjoy SDK 12.3.3.

## 12.3.2.0
* Certified with Tapjoy SDK 12.3.2.

## 12.3.1.0
* Certified with Tapjoy SDK 12.3.1.
* Use `NSJSONReadingAllowFragments` option for deserializing bid response.
* Add support for initialization status.

## 12.3.0.1
* Add support for setting whether the user is below the age of consent or not.

## 12.3.0.0
* Certified with Tapjoy SDK 12.3.0.
* Add Unity support for automatic dependency resolution. Please ensure that you are on the latest [AppLovin MAX Unity Plugin](https://bintray.com/applovin/Unity/applovin-max-unity-plugin).
* Support for tracking clicks.
* Add support for extra reward options.

## 12.2.1.1
* Minor adapter improvements.

## 12.2.1.0
* Certified with Tapjoy SDK 12.2.1.

## 12.2.0.2
* Bundle Tapjoy resources the way it is done in their Unity plugin.

## 12.2.0.1
* Set mediation to "applovin" per Tapjoy's request.

## 12.2.0.0
* Initial commit.
