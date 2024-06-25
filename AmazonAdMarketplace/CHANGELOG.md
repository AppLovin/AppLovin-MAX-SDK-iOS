# Changelog

## 4.9.6.0
* Certified with AmazonAdMarketplace SDK 4.9.6.

## 4.9.5.0
* Certified with AmazonAdMarketplace SDK 4.9.5.

## 4.9.4.0
* Certified with AmazonAdMarketplace SDK 4.9.4.

## 4.9.3.1
* Add error type information to signal collection error logs.

## 4.9.3.0
* Certified with AmazonAdMarketplace SDK 4.9.3.
* Updated minimum Xcode requirement to 15.0.

## 4.9.2.0
* Certified with AmazonAdMarketplace SDK 4.9.2.

## 4.9.1.0
* Certified with AmazonAdMarketplace SDK 4.9.1.
* Remove deprecated callbacks `didStartRewardedAdVideo` and `didCompleteRewardedAdVideo`.

## 4.9.0.0
* Certified with AmazonAdMarketplace SDK 4.9.0.

## 4.8.0.0
* Certified with AmazonAdMarketplace SDK 4.8.0.

## 4.7.8.0
* Certified with AmazonAdMarketplace SDK 4.7.8.

## 4.7.7.0
* Certified with AmazonAdMarketplace SDK 4.7.7.

## 4.7.6.0
* Certified with AmazonAdMarketplace SDK 4.7.6.

## 4.7.5.0
* Certified with AmazonAdMarketplace SDK 4.7.5.

## 4.7.4.0
* Certified with AmazonAdMarketplace SDK 4.7.4.

## 4.7.3.0
* Certified with AmazonAdMarketplace SDK 4.7.3.
* Updated minimum Xcode requirement to 14.1.

## 4.7.2.0
* Certified with APS SDK 4.7.2.
* Fixed potential memory leaks by clearing delegates in `destroy:` method.   

## 4.7.1.0
* Certified with APS SDK 4.7.1.

## 4.7.0.1
* Fix APS banner ads not loading on tablets in edge-case situations.

## 4.7.0.0
* Certified with APS SDK 4.7.0.
* Updated minimum Xcode requirement to 14.0.

## 4.6.0.0
* Certified with APS SDK 4.6.0.

## 4.5.6.4
* Add support for passing Amazon hashed bidder id (`amznp`) in `-[MAAdDelegate didLoadAd:]` callback via `-[MAAd adValueForKey:]`. AppLovin MAX SDK v11.7.0+ is required.

## 4.5.6.3
* Fix using incorrect mediation hints when same price point is used for different ad formats.

## 4.5.6.2
* Update to use `[MAAdapterError errorWithCode:errorString:thirdPartySdkErrorCode:thirdPartySdkErrorMessage:]` to avoid crashes with AppLovin SDK 11.4.1 and earlier.

## 4.5.6.1
* Add support for passing creative id to AppLovin SDK.
* Disable bitcode, as Apple deprecated it in Xcode 14 (https://developer.apple.com/documentation/xcode-release-notes/xcode-14-release-notes).
* Add additional details for ad display failures. 

## 4.5.6.0
* Certified with APS SDK 4.5.6. 
* Add try/catch to signal collection to avoid crashes.

## 4.5.5.0
* Certified with APS SDK 4.5.5.

## 4.5.4.0
* Certified with APS SDK 4.5.4.

## 4.5.2.2
* Fix `ALTAmazonMediationHints` memory leaks.

## 4.5.2.1
* Prevent crashes while retrieving APS SDK version.

## 4.5.2.0
* Certified with APS SDK 4.5.2.

## 4.5.0.0
* Certified with APS SDK 4.5.0 with rewarded video support.
* Add `adClicked` callback for interstitial ads.
* Move click callback from `bannerWillLeaveApplication:` to `adClicked` for banner ads.

## 4.4.3.1
* Remove DTBAdResponse and DTBAdErrorInfo objects from local extra parameters after they've been used.
* Distribute adapter as an XCFramework.
* Silence API deprecation warnings.

## 4.4.3.0
* Certified with APS SDK 4.4.3.

## 4.4.1.2
* Update ad display failed error code.

## 4.4.1.1
* Fix memory leak with DTBAdLoader objects.

## 4.4.1.0
* Certified with APS SDK 4.4.1 with interstitial video support.

## 4.3.1.5
* Add support for passing in a presenting view controller.

## 4.3.1.4
* Fix case where new ad loader might not be used when passed in.

## 4.3.1.3
* Add more logging.

## 4.3.1.2
* Add more logging.

## 4.3.1.1
* Add support for updating cached ad loaders with new ones passed in via local parameters.

## 4.3.1.0
* Certified with APS SDK 4.3.1.

## 4.3.0.0
* Update open source versions to allow compilation with AppLovin SDK v11.0.0+.
* Certified with APS SDK 4.3.0.

## 4.2.1.0
* Initial commit.
* Minimum AppLovin MAX SDK version 11.0.0.
