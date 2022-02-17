# Changelog

## 6.9.0.6
* Fix icon rendering for template native banners.

## 6.9.0.5
* Add support for true [native banner ads](https://developers.facebook.com/docs/audience-network/guides/ad-formats/native-banner/), which can be enabled on your MAX dashboard.

## 6.9.0.4
* Fix headline and advertiser views in native ads.

## 6.9.0.3
* Update open source versions to allow compilation with AppLovin SDK v11.0.0+.
* Address compiler warning about calling `loadAdWithBidPayload:` on a background thread.

## 6.9.0.2
* Fix icon view never getting registered for interaction.

## 6.9.0.1
* Add support for native custom ads and updated native template ad support.

## 6.9.0.0
* Certified with Facebook SDK 6.9.0.
* Specify Swift version 5.0 in the podspec to succesfully publish the Pod.

## 6.6.0.2
* Fix potential memory leak by cleaning up rewarded interstitial ad object.

## 6.6.0.1
* Initial support for true native ads.

## 6.6.0.0
* Certified with Facebook SDK 6.6.0.

## 6.5.1.0
* Certified with Facebook SDK 6.5.1.

## 6.5.0.0
* Certified with Facebook SDK 6.5.0.

## 6.4.1.0
* Certified with Facebook SDK 6.4.1.
* Remove waterfall placements support.
* Update podspec to use `pod_target_xcconfig` over the deprecated `xcconfig`.

## 6.3.1.0
* Certified with SDK 6.3.1.

## 6.3.0.0
* Certified with SDK 6.3.0.
* Add support to pass 3rd-party error code and description to SDK.
* Update podspec source from bintray to S3.

## 6.2.1.0
* Certified with SDK 6.2.1.

## 6.2.0.1
* Add checks for nil `MANativeAdView` components.
* Add ability to set custom template for native banners.

## 6.2.0.0
* Certified with SDK 6.2.0.

## 6.0.0.3
* Certified with SDK 6.0.0.

## 5.10.1.8
* Add support for vertical template native banners.

## 5.10.1.7
* Update 7000000 version check to 6140000.

## 5.10.1.6
* Update to fail native ad view ad if ad object is nil or invalid.

## 5.10.1.5
* Update native banners to load the default provided template if SDK version is not at least 7000000.
* Removed the i386 slice. Adapter will no longer work on 32-bit simulators.

## 5.10.1.4
* Update 70000 version check to 7000000.

## 5.10.1.3
* Update 61400 version check to 70000.

## 5.10.1.2
* Update custom layout for native leader ads.
* Fix rendering native banner and MREC ads.
* Fix impressions for native adview ads.

## 5.10.1.1
* Added support for rewarded interstitial ads.

## 5.10.1.0
* Certified with SDK 5.10.1.

## 5.10.0.3
* Fix incorrect adapter version returned by the adapter.

## 5.10.0.2
* Updated to not set mixed audience if age restricted user setting is nil.

## 5.10.0.1
* Actually certified with SDK 5.10.1.

## 5.10.0.0
* Certified with SDK 5.10.0.

## 5.9.0.0
* Certified with SDK 5.9.0.

## 5.8.0.1
* Add support for native ad views.
* Call the `didExpandAdViewAd` callback when clicking banners, to match the corresponding `didCollapseAdViewAd`. 

## 5.8.0.0
* Certified with SDK 5.8.0.

## 5.7.1.0
* Certified with SDK 5.7.1.

## 5.7.0.0
* Certified with SDK 5.7.0.

## 5.6.1.0
* Certified with SDK 5.6.1.

## 5.6.0.0
* Updated the minimum required AppLovin SDK version to 6.5.0.
* Certified with SDK 5.6.0.

## 5.5.1.0
* Certified with SDK 5.5.1.

## 5.5.0.0
* Certified with SDK 5.5.0.

## 5.4.0.2
* Re-certified with SDK 5.4.0.
* Add support for initialization status.

## 5.4.0.1
* Revert back to depending on FAN SDK 5.3.2 as FAN SDK 5.4.0 depends on `FBSDKCoreKit.framework` which conflicts with manual integrations already bundling that framework in Unity. 

## 5.4.0.0
* Certified with SDK 5.4.0.
* Update logging.
* Better error code mapping.
* Remove custom initialization code for older versions of FAN (below 5.2.0).

## 5.3.2.1
* Add Unity support for automatic dependency resolution. Please ensure that you are on the latest [AppLovin MAX Unity Plugin](https://bintray.com/applovin/Unity/applovin-max-unity-plugin).

## 5.3.2.0
* Certified with SDK 5.3.2.
* Add support for extra reward options.

## 5.3.1.1
* Fix initialization related to last update.

## 5.3.1.0
* Certified with SDK 5.3.1.

## 5.2.0.3
* Fix using wrong AppLovin MAX callback when failing fullscreen ad displagy. Using `didFailToDisplayInterstitialAdWithError:` and `didFailToDisplayRewardedAdWithError:` now.

## 5.2.0.2
* Minor adapter improvements.

## 5.2.0.1
* Set mediation provider as APPLOVIN_X.X.X:Y.Y.Y.Y where X.X.X is AppLovin's SDK version and Y.Y.Y.Y is the adapter version.

## 5.2.0.0
* Support for FAN SDK 5.2.0.
* Use new FAN SDK initialization APIs.

## 5.1.1.1
* Synchronize usage of `FBAdSettings` as that is not thread-safe.

## 5.1.1.0
* Update to Facebook SDK 5.1.1 with fix for header bidding.

## 5.1.0.1
* Turn off Facebook SDK verbose logging.

## 5.1.0.0
* Initial commit.
