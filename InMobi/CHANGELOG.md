# Changelog

## 10.7.4.0
* Certified with InMobi SDK 10.7.4.
* Updated minimum Xcode requirement to 15.0.

## 10.7.2.0
* Certified with InMobi SDK 10.7.2.
* Remove deprecated callbacks `didStartRewardedAdVideo` and `didCompleteRewardedAdVideo`.

## 10.7.1.0
* Certified with InMobi SDK 10.7.1.

## 10.7.0.0
* Certified with InMobi SDK 10.7.0.
* Updated minimum iOS version to 12.0.

## 10.6.4.0
* Certified with InMobi SDK 10.6.4.

## 10.6.0.0
* Certified with InMobi SDK 10.6.0.

## 10.5.8.1
* Updated to use `+[IMPrivacyCompliance setDoNotSell:]` API to set CCPA values.
* Updated error code mapping to include new error codes.

## 10.5.8.0
* Certified with InMobi SDK 10.5.8.

## 10.5.6.0
* Certified with InMobi's Swift SDK 10.5.6.

## 10.1.4.2
* Updated minimum Xcode requirement to 14.1.
* Fixed potential memory leaks by clearing delegates in `destroy:` method.
* Revert temporary workaround for the issue where `bannerAdImpressed:` is called before `bannerDidFinishLoading:`.    

## 10.1.4.1
* Add a temporary workaround for the issue where `bannerAdImpressed:` is called before `bannerDidFinishLoading:.`

## 10.1.4.0
* Certified with InMobi SDK 10.1.4.
* Remove the `privacySettingForSelector:fromParameters:` function and call privacy methods directly.
* Now requires MAX SDK version 6.14.0 or higher. 

## 10.1.3.0
* Certified with InMobi SDK 10.1.3.

## 10.1.2.7
* Add support for test mode for simulators.

## 10.1.2.6
* Remove `consentDialogState` guard.

## 10.1.2.5
* Add support for star ratings in manual native ads.

## 10.1.2.4
* Add CCPA support.

## 10.1.2.3
* Update to use `[MAAdapterError errorWithCode:errorString:thirdPartySdkErrorCode:thirdPartySdkErrorMessage:]` to avoid crashes with AppLovin SDK 11.4.1 and earlier.

## 10.1.2.2
* Fix broken native CTA button and duplicate click callbacks for other views.

## 10.1.2.1
* Fix duplicate click callbacks fired for native CTA button.

## 10.1.2.0
* Certified with InMobi SDK 10.1.2.

## 10.1.1.1
* Support for native ads in external plugins (e.g. React Native).
* Disable bitcode, as Apple deprecated it in Xcode 14 (https://developer.apple.com/documentation/xcode-release-notes/xcode-14-release-notes).

## 10.1.1.0
* Certified with InMobi SDK 10.1.1.
* Add additional details for ad display failures. 

## 10.1.0.2
* Add support for native ad view ads.

## 10.1.0.1
* Fix wrong property used for InMobi native ad description.

## 10.1.0.0
* Certified with InMobi SDK 10.1.0.

## 10.0.8.2
* Add impression callbacks for banners, MRECs, interstitials and rewarded ads.

## 10.0.8.1
* Silence API deprecation warnings.
* Use local scope copy of native ad while preparing view.
* Update consent status before collecting signal. 

## 10.0.8.0
* Certified with InMobi SDK 10.0.8.

## 10.0.7.0
* Certified with InMobi SDK 10.0.7.

## 10.0.6.0
* Certified with InMobi SDK 10.0.6.
* Distribute adapter as an XCFramework.

## 10.0.5.4
* Update ad display failed error code.

## 10.0.5.3
* Specify `MANativeAdAdapter` for adapter to enable it for test ads in Mediation Debugger.

## 10.0.5.2
* Fix native ad media content rendering.

## 10.0.5.1
* Remove check for manual native ad assets.

## 10.0.5.0
* Certified with InMobi SDK 10.0.5.

## 10.0.2.2
* Add support for passing native ads.

## 10.0.2.1
* Add support for passing in a presenting view controller.

## 10.0.2.0
* Certified with InMobi SDK 10.0.2.
* Update open source versions to allow compilation with AppLovin SDK v11.0.0+.

## 10.0.1.1
* Fix interstitials not reporting creative id correctly.

## 10.0.1.0
* Certified with InMobi SDK 10.0.1.
* Update signal collection APIs.

## 9.2.1.1
* Update consent dictionary and API used to set GDPR info.
* Update GDPR before signal collection.

## 9.2.1.0
* Certified with InMobi SDK 9.2.1.
* Update podspec to use `pod_target_xcconfig` over the deprecated `xcconfig`.

## 9.1.7.0
* Certified with InMobi SDK 9.1.7.

## 9.1.5.0
* Certified with InMobi SDK 9.1.5.
* Update podspec source from bintray to S3.

## 9.1.1.1
* Add support for passing creative id to SDK (supported in iOS SDK 6.15.0+).
* Add support to pass 3rd-party error code and description to SDK.

## 9.1.1.0
* Certified with InMobi SDK 9.1.1.

## 9.1.0.1
* Only set user consent flag if GDPR applies.

## 9.1.0.0
* Certified with InMobi SDK 9.1.0.

## 9.0.7.9
* Update 7000000 version check to 6140000.
* Update initialization log.

## 9.0.7.8
* Update signal collection to fail early if InMobi SDK is not initialized successfully.
* Removed the i386 slice. Adapter will no longer work on 32-bit simulators.

## 9.0.7.7
* Fix delay caused by invalid placement identifier handling in signal collection.

## 9.0.7.6
* Update 70000 version check to 7000000.

## 9.0.7.5
* Fix incorrect adapter version returned by the adapter.

## 9.0.7.4
* Updated to not set privacy settings if nil.

## 9.0.7.3
* Roll back privacy changes.

## 9.0.7.2
* Update deprecated callbacks (`interstitial:didReceiveWithMetaInfo:`) for interstitial and rewarded ads.
* Updated to not set privacy settings if nil.

## 9.0.7.1
* Fix bidding for leaders by mapping "leaders" placement key to "banners" placement key. 

## 9.0.7.0
* Certified with SDK 9.0.7.
* Add support for bidding.

## 9.0.6.1
* Point to `InMobiSDK/Core`.

## 9.0.6.0
* Certified with SDK 9.0.6.
* Track initialization status with new initialization complete callback.

## 9.0.4.0
* Certified with SDK 9.0.4.

## 9.0.3.1
* Add support for medium rectangle ad views.

## 9.0.3.0
* Certified with SDK 9.0.3.

## 9.0.1.2
* Added banner display callback to `bannerDidFinishLoading:`.

## 9.0.1.1
* Moved interstitial and rewarded display callbacks from `interstitialWillPresent:` to `interstitialDidPresent:`.

## 9.0.1.0
* Certified with SDK 9.0.1.

## 9.0.0.0
* Certified with SDK 9.0.0.
* Removed unused server parameters.
* Updated the minimum required AppLovin SDK version to 6.5.0.
* Removed support for muting/un-muting of ads.

## 7.3.2.1
* Format `IM_GDPR_CONSENT_AVAILABLE` value to true/false.

## 7.3.2.0
* Certified with SDK 7.3.2.

## 7.3.1.1
* Uncertify  SDK 7.3.1, re-certify against SDK 7.2.9 due to `isReady` bug.

## 7.3.1.0
* Certified with SDK 7.3.1.
* Add support for initialization status.

## 7.2.9.0
* Add Unity support for automatic dependency resolution. Please ensure that you are on the latest [AppLovin MAX Unity Plugin](https://bintray.com/applovin/Unity/applovin-max-unity-plugin).
* Add support for extra reward options.

## 7.2.7.2
* Minor adapter improvements.

## 7.2.7.1
* Use `interstitialWillPresent:` instead of `interstitialDidPresent:` for impression tracking.

## 7.2.7.0
* Initial commit.
