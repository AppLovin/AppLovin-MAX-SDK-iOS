# Changelog

## x.x.x.x
* Fix initialization status bug. 

## 2.0.0.0
* Certified with Snap SDK 2.0.0.
* Add support for bidding.
* Add support for test mode.
* Update podspec to use `pod_target_xcconfig` over the deprecated `xcconfig`.

## 1.0.7.3
* Add support for banner, MREC, and rewarded ads.
* Update podspec source from bintray to S3.

## 1.0.7.2
* Certified with Snap SDK 1.0.7. Note that 1.0.7 requires lowercased SKAdNetwork ID and is bundled as a dylib, meaning publishers need to be on our Unity Plugin v3.2.3 to auto-embed the dylib on Unity v2019.3.3+.

## 1.0.7.1
* Add support to pass 3rd-party error code and description to SDK.
* Downgraded to Snap SDK 1.0.6 because 1.0.7 is distributed as a dylib.

## 1.0.7.0
* Certified with Snap SDK 1.0.7.

## 1.0.6.2
* Update `SDKVersion` to return empty string if `[SAKMobileAd shared].sdkVersion` returns nil.

## 1.0.6.1
* Update `[ALSnapMediationAdapterInterstitialAdDelegate interstital:didFailWithError:]` to `[ALSnapMediationAdapterInterstitialAdDelegate interstitial:didFailWithError:]` to prevent crash.

## 1.0.6.0
* Certified with Snap SDK 1.0.6.

## 1.0.4.2
* Update initialization log.

## 1.0.4.1
* Removed the i386 slice. Adapter will no longer work on 32-bit simulators.

## 1.0.4.0
* Initial commit.
