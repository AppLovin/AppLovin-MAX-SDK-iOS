# Changelog

## 4.1.2.0
* Certified with OguryPresage SDK 4.1.2.
* Remove the `privacySettingForSelector:fromParameters:` function and call privacy methods directly.
* Remove unnecessary MAX SDK version check.

## 4.1.1.3
* Enable banner and MREC ads for Mediation Debugger.

## 4.1.1.2
* Add bidding support for rewarded, banner, and MREC ads.

## 4.1.1.1
* Add support for IAB's TCFv2 GDPR consent string. Note that you must be on the AppLovin MAX SDK v11.4.2+ and use a TCFv2-compliant framework which stores the consent string in User Defaults via the `IABTCF_TCString` key to use this feature. 

## 4.1.1.0
* Certified with OguryPresage SDK 4.1.1.

## 4.1.0.0
* Certified with OguryPresage SDK 4.1.0.

## 4.0.0.0
* Certified with OguryPresage SDK 4.0.0.

## 2.6.3.2
* Remove `consentDialogState` guard.

## 2.6.3.1
* Update to use `+[MAAdapterError errorWithCode:errorString:thirdPartySdkErrorCode:thirdPartySdkErrorMessage:]` to avoid crashes with AppLovin SDK 11.4.1 and earlier.

## 2.6.3.0
* Certified with OguryPresage SDK 2.2.0.
* Disable bitcode, as Apple deprecated it in Xcode 14 (https://developer.apple.com/documentation/xcode-release-notes/xcode-14-release-notes).
* Add additional details for ad display failures. 

## 2.6.2.1
* Update privacy settings before collecting signal. 

## 2.6.2.0
* Certified with OguryPresage SDK 2.1.0.
* Distribute adapter as an XCFramework.
* Silence API deprecation warnings.

## 2.6.1.1
* Update ad display failed error code.

## 2.6.1.0
* Certified with OguryPresage SDK 2.0.1.
* Remove `OguryChoiceManager` dependency from podspec and Podfile as it is now part of `OgurySdk` pod.

## 2.6.0.1
* Add support for passing in a presenting view controller.

## 2.6.0.0
* Use Ogury SDK 2.0.0 and Ogury Ads 3.0.0. Support for Header Bidding.
* Update open source versions to allow compilation with AppLovin SDK v11.0.0+.

## 2.5.1.0
* Certified with OguryPresage SDK 2.5.1.

## 2.3.5.3
* Update to new initialization API: `setupWithAssetKey:andCompletionHandler:`.

## 2.3.5.2
* Remove banner support.

## 2.3.5.1
* Use `huc` for GDPR consent status.
* Update OguryChoiceManager version to 3.1.8 in podspec.

## 2.3.5.0
* Certified with OguryPresage SDK 2.3.5.
* Add support for new impression callback.
* Update podspec to use `pod_target_xcconfig` over the deprecated `xcconfig`.

## 2.3.3.0
* Initial commit.
