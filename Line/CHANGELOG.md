# Changelog

## 2.4.20220607.0
* Certified with Line SDK 2.4.20220607.
* Distribute adapter as an XCFramework.
* Silence API deprecation warnings.

## 2.4.20211028.3
* Update ad display failed error code.

## 2.4.20211028.2
* Update SDK version retrieval API.

## 2.4.20211028.1
* Remove check for manual native ad assets.

## 2.4.20211028.0
* Certified with Line SDK 2.4.20211028.
* Update open source versions to allow compilation with AppLovin SDK v11.0.0+.
* Update mute setting API to use `enableSoundByDefault()` instead of `enableSound()`. NOTE: The mute state can only be set at SDK initialization, hence, the mute state at time of ad display may not reflect the current mute state.
* Update impression callback to `fiveAdDidImpression()` to replace `fiveAdDidImpressionImage()`.
* Improve error handling.
* Remove `FADConfig.fiveAdFormat` since it is deprecated.

## 2.4.20211004.4
* Fix non-deterministic LINE media view behavior resulting from calling the getter more than once. 

## 2.4.20211004.3
* Update open source versions to allow compilation with AppLovin SDK v11.0.0+.
* Fix UI thread warnings by running ad view and native ad creation and loads on main thread.
* Fix potential media view resizing by setting content mode explicitly.

## 2.4.20211004.2
* Fix icon view never getting registered for interaction.

## 2.4.20211004.1
* Add support for native custom ads and updated native template ad support.

## 2.4.20211004.0
* Certified with Line SDK 2.4.20211004.
* Replace `FADDelegate` with `FADLoadDelegate` and `FADAdViewEventListener`.
* Add `didFailedToShowAdWithError` for display failure.
* Update error codes.

## 2.3.20210326.3
* Fix issue causing native ads to time out.

## 2.3.20210326.2
* Initial support for true native ads.

## 2.3.20210326.1
* Always mute banner and MREC ads.

## 2.3.20210326.0
* Update podspec to use `pod_target_xcconfig` over the deprecated `xcconfig`.
* Update dependency to point to LINE's public pod `FiveAd`.
  
## 2020.12.22.0
* Initial commit.
