# Changelog

## 21.7.1.4
* Add log for "is_location_collection_enabled" value.

## 21.7.1.3
* Add support for passing in a presenting view controller.

## 21.7.1.2
* Add support for passing local parameter "is_location_collection_enabled" to set `SmaatoSDK.gpsEnabled` for signal collection.
 
## 21.7.1.1
* Add support for passing local parameter "is_location_collection_enabled" to set `SmaatoSDK.gpsEnabled`.

## 21.7.1.0
* Certified with Smaato SDK 21.7.1.

## 21.7.0.1
* Fix native ads CTA button not clicking through.

## 21.7.0.0
* Certified with Smaato SDK 21.7.0.
* Update open source versions to allow compilation with AppLovin SDK v11.0.0+.

## 21.6.19.1
* Add support for native custom ads and native template ads.

## 21.6.19.0
* Certified with Smaato SDK 21.6.19.
* Add back signal collection.

## 21.6.17.1
* Comment out signal collection code.
* Downgrade Smaato SDK to 21.6.16 due to Xcode 12.5 requirement.

## 21.6.17.0
* Certified with Smaato SDK 21.6.17.
* Add signal collection.

## 21.6.16.0
* Certified with Smaato SDK 21.6.16.

## 21.6.14.0
* Update podspec to use `pod_target_xcconfig` over the deprecated `xcconfig`.
* Certified with Smaato SDK 21.6.14.

## 21.6.10.2
* Update podspec source from bintray to S3.
* Update ad load to fail if bid response is valid but ad request creation is not.
* Update ad load to use old API if bid response is not valid.

## 21.6.10.1
* Add support for passing creative id to SDK (supported in iOS SDK 6.15.0+).

## 21.6.10.0
* Certified with Smaato SDK 21.6.10.
* Add support to pass 3rd-party error code and description to SDK.

## 21.6.6.0
* Certified with Smaato SDK 21.6.6.

## 21.6.2.0
* Certified with Smaato SDK 21.6.2.

## 21.6.0.0
* Certified with Smaato SDK 21.6.0.

## 21.5.2.3
* Removed the i386 slice. Adapter will no longer work on 32-bit simulators.
* Update 7000000 version check to 6140000.
* Update initialization log.

## 21.5.2.2
* Remove unsupported GDPR consent setting code and remove previously set values.

## 21.5.2.1
* Update 70000 version check to 7000000.

## 21.5.2.0
* Add support for bidding (signal collection not required).

## 21.3.3.4
* Fix incorrect adapter version returned by the adapter.

## 21.3.3.3
* Updated to not set age restriction setting if nil.

## 21.3.3.2
* Roll back privacy changes.

## 21.3.3.1
* Fix code inconsistency with other adapters.
* Updated to not set age restriction setting if nil.

## 21.3.3.0
* Certified with SDK 21.3.3.

## 21.3.1.0
* Certified with SDK 21.3.1.

## 21.2.2.1
* Match Android's fix for Smaato crashes at the recommendation of Smaato's SDK team by calling all Smaato SDK APIs _after_ `Smaato.init(...)`.

## 21.2.2.0
* Certified with SDK 21.2.2.

## 21.2.1.0
* Certified with SDK 21.2.1.

## 21.1.2.0
* Certified with SDK 21.1.2.
* Updated the minimum required AppLovin SDK version to 6.5.0.

## 10.2.3.0
* Certified with SDK 10.2.3.
* Remove unused server parameters.

## 10.2.1.0
* Certified with SDK 10.2.1

## 10.2.0.2
* Add support for initialization status.

## 10.2.0.1
* Add Unity support for automatic dependency resolution. Please ensure that you are on the latest [AppLovin MAX Unity Plugin](https://bintray.com/applovin/Unity/applovin-max-unity-plugin).
* Add support for extra reward options.

## 10.2.0.0
* Certified with SDK 10.2.0.
* GDPR fixes.

## 10.1.2.1
* GDPR fixes.
  
## 10.1.2.0
* Initial commit.
